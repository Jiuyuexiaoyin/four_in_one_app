import java.awt.AlphaComposite;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.GraphicsEnvironment;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.font.FontRenderContext;
import java.awt.font.LineMetrics;
import java.awt.font.TextAttribute;
import java.awt.font.TextLayout;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Path2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RoundRectangle2D;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.AttributedCharacterIterator;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageTypeSpecifier;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.metadata.IIOMetadataNode;
import javax.imageio.stream.ImageOutputStream;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Dependency-free renderer for the controlled Get Ready SVG masters.
 *
 * Run in Java source-file mode through generate_getready_assets.ps1. The
 * renderer intentionally implements only the SVG elements used by the masters:
 * svg, g, rect, circle, path, text, title, and desc. Paths accept only absolute
 * move, line, cubic, and close commands. Anything capable of embedding or
 * referencing external artwork is rejected before rendering.
 */
public final class GenerateGetreadyAssets {
  private static final int SUPERSAMPLE = 4;

  private static final Color DEEP_SPACE_BLACK = rgb("111111");
  private static final Color DEEP_GRAY_BLUE = rgb("6B7280");
  private static final Color TECHNOLOGY_GREEN = rgb("16A34A");
  private static final Color OFF_WHITE = rgb("F6F7F8");
  private static final Color PURE_WHITE = rgb("FFFFFF");
  private static final Color MUTED_TEXT = rgb("E5E7EB");
  private static final Color PANEL_BORDER = rgb("6B7280");

  private static final Set<String> ALLOWED_ELEMENTS = Set.of(
      "svg", "g", "rect", "circle", "path", "text", "title", "desc");
  private static final Set<String> FORBIDDEN_ATTRIBUTES = Set.of(
      "href", "xlink:href", "filter", "mask", "clip-path", "style", "transform");
  private static final Pattern PATH_TOKEN = Pattern.compile(
      "[A-Za-z]|[-+]?(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE][-+]?\\d+)?");
  private static final String APPROVED_REFERENCE_RELATIVE =
      ".ai_reference/branding/get_ready_2_6_brand_board.png";
  private static final String APPROVED_REFERENCE_SHA256 =
      "3a3fc9f7e1cbf7cb03b5af7913337d36e5ed7714b10d6d7a424bfc8eb021ec47";
  private static final double ARC_FRAME_X = 190.0;
  private static final double ARC_FRAME_Y = 185.0;
  private static final double ARC_FRAME_WIDTH = 525.0;
  private static final double ARC_FRAME_HEIGHT = 605.0;
  private static final String MASTER_ARC_PATH =
      "M675 300 C660 240 552 218 472 226 C326 236 230 351 230 497 C230 637 330 744 460 750";

  private static final Map<String, String> AVAILABLE_FONTS = loadAvailableFonts();
  private static final LinkedHashSet<String> USED_FONTS = new LinkedHashSet<>();

  private enum Theme {
    DEFAULT,
    LIGHT
  }

  private enum MaskKind {
    NONE,
    CIRCLE,
    SQUIRCLE
  }

  private record SvgDocument(
      Path path,
      double viewX,
      double viewY,
      double viewWidth,
      double viewHeight,
      Document document) {}

  private record OutputInfo(
      String path,
      int width,
      int height,
      boolean alpha,
      long bytes,
      String sha256,
      String source) {}

  private GenerateGetreadyAssets() {}

  public static void main(String[] args) throws Exception {
    if (Runtime.version().feature() < 21) {
      throw new IllegalStateException(
          "OpenJDK 21 or newer is required; found " + Runtime.version());
    }

    Path repoRoot = parseRepoRoot(args);
    Map<String, SvgDocument> masters = loadMasters(repoRoot);
    assertCorrectedGeometry(masters);
    List<OutputInfo> outputs = new ArrayList<>();

    generateBrandRasters(repoRoot, masters, outputs);
    generateAndroidRasters(repoRoot, masters, outputs);
    generateProofSheets(repoRoot, masters, outputs);
    writeManifest(repoRoot, masters, outputs);

    System.out.println("Generated " + outputs.size() + " verified PNG assets.");
    System.out.println("Manifest: assets\\branding\\generated\\get_ready_asset_manifest.json");
  }

  private static Path parseRepoRoot(String[] args) throws IOException {
    String value = null;
    for (String arg : args) {
      if (arg.startsWith("--repo-root=")) {
        value = arg.substring("--repo-root=".length());
      } else {
        throw new IllegalArgumentException("Unsupported argument: " + arg);
      }
    }
    if (value == null || value.isBlank()) {
      throw new IllegalArgumentException("Missing required --repo-root=<path> argument");
    }

    Path root = Path.of(value).toAbsolutePath().normalize();
    if (!Files.isDirectory(root) || !Files.isRegularFile(root.resolve("pubspec.yaml"))) {
      throw new IOException("Not a Flutter repository root: " + root);
    }
    return root;
  }

  private static Map<String, SvgDocument> loadMasters(Path root) throws Exception {
    Map<String, String> files = new LinkedHashMap<>();
    files.put("mark", "assets/branding/get_ready_mark.svg");
    files.put("markDark", "assets/branding/get_ready_mark_dark.svg");
    files.put("markLight", "assets/branding/get_ready_mark_light.svg");
    files.put("markMonochrome", "assets/branding/get_ready_mark_monochrome.svg");
    files.put("wordmarkHorizontal", "assets/branding/get_ready_wordmark_horizontal.svg");
    files.put("logoVertical", "assets/branding/get_ready_logo_vertical.svg");
    files.put("splash", "assets/branding/get_ready_splash_logo.svg");
    files.put("notification", "assets/branding/get_ready_notification_mark.svg");

    Map<String, SvgDocument> result = new LinkedHashMap<>();
    for (Map.Entry<String, String> entry : files.entrySet()) {
      Path path = root.resolve(entry.getValue()).normalize();
      if (!Files.isRegularFile(path)) {
        throw new IOException("Missing SVG master: " + path);
      }
      result.put(entry.getKey(), parseSvg(path));
    }
    return result;
  }

  private static SvgDocument parseSvg(Path path) throws Exception {
    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    factory.setNamespaceAware(true);
    factory.setXIncludeAware(false);
    factory.setExpandEntityReferences(false);
    factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
    factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
    factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
    setFeatureIfSupported(factory, "http://apache.org/xml/features/disallow-doctype-decl", true);
    setFeatureIfSupported(factory, "http://xml.org/sax/features/external-general-entities", false);
    setFeatureIfSupported(factory, "http://xml.org/sax/features/external-parameter-entities", false);

    DocumentBuilder builder = factory.newDocumentBuilder();
    Document document = builder.parse(path.toFile());
    Element root = document.getDocumentElement();
    if (!"svg".equals(elementName(root))) {
      throw new IllegalArgumentException("Root element must be <svg>: " + path);
    }

    validateSvgGrammar(path, root);
    double[] viewBox = parseNumberList(requireAttribute(root, "viewBox"), 4, "viewBox", path);
    if (viewBox[2] <= 0 || viewBox[3] <= 0) {
      throw new IllegalArgumentException("SVG viewBox must have positive dimensions: " + path);
    }
    return new SvgDocument(path, viewBox[0], viewBox[1], viewBox[2], viewBox[3], document);
  }

  private static void setFeatureIfSupported(
      DocumentBuilderFactory factory, String feature, boolean value) {
    try {
      factory.setFeature(feature, value);
    } catch (Exception exception) {
      throw new IllegalStateException("Required secure XML feature unavailable: " + feature, exception);
    }
  }

  private static void validateSvgGrammar(Path path, Element root) {
    NodeList elements = root.getElementsByTagNameNS("*", "*");
    for (int index = 0; index < elements.getLength(); index++) {
      Element element = (Element) elements.item(index);
      String name = elementName(element);
      if (!ALLOWED_ELEMENTS.contains(name)) {
        throw new IllegalArgumentException(
            "Unsupported SVG element <" + name + "> in " + path
                + ". Embedded images, paths, filters, gradients, masks, and arbitrary shapes are forbidden.");
      }
      validateElementAttributes(path, element);
    }
    validateElementAttributes(path, root);
  }

  private static void validateElementAttributes(Path path, Element element) {
    NamedNodeMap attributes = element.getAttributes();
    for (int index = 0; index < attributes.getLength(); index++) {
      Node attribute = attributes.item(index);
      String name = attribute.getNodeName().toLowerCase(Locale.ROOT);
      String value = attribute.getNodeValue();
      if (FORBIDDEN_ATTRIBUTES.contains(name)) {
        throw new IllegalArgumentException(
            "Forbidden SVG attribute '" + name + "' in " + path);
      }
      if (value != null && value.toLowerCase(Locale.ROOT).contains("url(")) {
        throw new IllegalArgumentException(
            "External or referenced SVG paint is forbidden in " + path + ": " + name);
      }
    }

    String name = elementName(element);
    if ("rect".equals(name) || "circle".equals(name) || "text".equals(name)) {
      String fill = requireAttribute(element, "fill");
      parseSvgColor(fill, path);
      if (element.hasAttribute("data-light-fill")) {
        parseSvgColor(element.getAttribute("data-light-fill"), path);
      }
      if (element.hasAttribute("stroke")
          && !"none".equalsIgnoreCase(element.getAttribute("stroke").trim())) {
        throw new IllegalArgumentException("Strokes are not supported in master SVGs: " + path);
      }
    }
    if ("path".equals(name)) {
      parseSvgPath(requireAttribute(element, "d"), path);
      String fill = element.hasAttribute("fill") ? element.getAttribute("fill").trim() : "none";
      String stroke = element.hasAttribute("stroke")
          ? element.getAttribute("stroke").trim()
          : "none";
      boolean hasFill = !"none".equalsIgnoreCase(fill);
      boolean hasStroke = !"none".equalsIgnoreCase(stroke);
      if (!hasFill && !hasStroke) {
        throw new IllegalArgumentException("A <path> must have a fill or stroke in " + path);
      }
      if (hasFill) {
        parseSvgColor(fill, path);
        if (element.hasAttribute("data-light-fill")) {
          parseSvgColor(element.getAttribute("data-light-fill"), path);
        }
      }
      if (hasStroke) {
        parseSvgColor(stroke, path);
        if (element.hasAttribute("data-light-stroke")) {
          parseSvgColor(element.getAttribute("data-light-stroke"), path);
        }
        double width = number(element, "stroke-width", Double.NaN, path);
        if (!(width > 0.0)) {
          throw new IllegalArgumentException("A stroked <path> needs positive stroke-width in " + path);
        }
        String lineCap = element.getAttribute("stroke-linecap").trim();
        if (!lineCap.isEmpty() && !"round".equals(lineCap)) {
          throw new IllegalArgumentException(
              "Only round path line caps are supported in " + path + ": " + lineCap);
        }
      }
    }
  }

  private static void generateBrandRasters(
      Path root, Map<String, SvgDocument> masters, List<OutputInfo> outputs) throws Exception {
    SvgDocument primary = masters.get("mark");
    for (int size : new int[] {1024, 512, 256, 128, 64, 32, 24, 16}) {
      String relative = "assets/branding/generated/get_ready_mark_" + size + ".png";
      writeOutput(root, relative,
          renderSvg(primary, size, size, Theme.DEFAULT, MaskKind.NONE, null),
          relativePath(root, primary.path()), outputs);
    }

    SvgDocument horizontal = masters.get("wordmarkHorizontal");
    writeOutput(root, "assets/branding/generated/get_ready_wordmark_horizontal.png",
        renderSvg(horizontal, 1600, 400, Theme.DEFAULT, MaskKind.NONE, null),
        relativePath(root, horizontal.path()), outputs);

    SvgDocument splash = masters.get("splash");
    writeOutput(root, "assets/branding/generated/get_ready_splash_dark.png",
        renderSvg(splash, 1440, 2560, Theme.DEFAULT, MaskKind.NONE, null),
        relativePath(root, splash.path()) + "#dark", outputs);
    writeOutput(root, "assets/branding/generated/get_ready_splash_light.png",
        renderSvg(splash, 1440, 2560, Theme.LIGHT, MaskKind.NONE, null),
        relativePath(root, splash.path()) + "#light", outputs);

    assertBrandColors(root.resolve("assets/branding/generated/get_ready_mark_1024.png"));
  }

  private static void generateAndroidRasters(
      Path root, Map<String, SvgDocument> masters, List<OutputInfo> outputs) throws Exception {
    Map<String, Integer> densitySizes = new LinkedHashMap<>();
    densitySizes.put("mdpi", 48);
    densitySizes.put("hdpi", 72);
    densitySizes.put("xhdpi", 96);
    densitySizes.put("xxhdpi", 144);
    densitySizes.put("xxxhdpi", 192);

    SvgDocument primary = masters.get("mark");
    for (Map.Entry<String, Integer> density : densitySizes.entrySet()) {
      String directory = "android/app/src/main/res/mipmap-" + density.getKey() + "/";
      int size = density.getValue();
      writeOutput(root, directory + "ic_launcher.png",
          renderSvg(primary, size, size, Theme.DEFAULT, MaskKind.NONE, null),
          relativePath(root, primary.path()) + "#legacy-" + density.getKey(), outputs);
      writeOutput(root, directory + "ic_launcher_round.png",
          renderSvg(primary, size, size, Theme.DEFAULT, MaskKind.CIRCLE, null),
          relativePath(root, primary.path()) + "#round-" + density.getKey(), outputs);
    }

    SvgDocument vertical = masters.get("logoVertical");
    writeOutput(root, "android/app/src/main/res/drawable-nodpi/getready_splash_brand.png",
        renderSvg(vertical, 720, 900, Theme.DEFAULT, MaskKind.NONE, null),
        relativePath(root, vertical.path()) + "#android-centered-brand", outputs);
  }

  private static void generateProofSheets(
      Path root, Map<String, SvgDocument> masters, List<OutputInfo> outputs) throws Exception {
    String proofRoot = "reports/p11_get_ready_brand_assets/";
    BufferedImage reference = loadApprovedReference(root);
    try {
      writeOutput(root, proofRoot + "reference_crops/reference_primary_mark.png",
          createReferenceCrop(reference, 61, 82, 210, 214, 4),
          APPROVED_REFERENCE_RELATIVE + "#crop-61,82,210,214", outputs);
      writeOutput(root, proofRoot + "reference_crops/reference_construction_mark.png",
          createReferenceCrop(reference, 65, 429, 247, 252, 4),
          APPROVED_REFERENCE_RELATIVE + "#crop-65,429,247,252", outputs);
      writeOutput(root, proofRoot + "reference_crops/reference_launcher_mark.png",
          createReferenceCrop(reference, 899, 413, 152, 150, 4),
          APPROVED_REFERENCE_RELATIVE + "#crop-899,413,152,150", outputs);

      writeOutput(root, proofRoot + "get_ready_master_contact_sheet.png",
          createContactSheet(masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_corrected_contact_sheet.png",
          createContactSheet(masters), "corrected geometry proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_silhouette_corrected_contact_sheet.png",
          createContactSheet(masters), "silhouette-lock contact sheet", outputs);
      writeOutput(root, "docs/screenshots/get_ready_branding.png",
          createContactSheet(masters), "corrected README brand proof", outputs);
      writeOutput(root, proofRoot + "get_ready_launcher_mask_preview.png",
          createLauncherMaskPreview(masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_dark_light_preview.png",
          createDarkLightPreview(masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_small_size_preview.png",
          createSmallSizePreview(root), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_corrected_small_size_preview.png",
          createSmallSizePreview(root), "corrected geometry small-size proof", outputs);
      writeOutput(root, proofRoot + "get_ready_silhouette_small_size_preview.png",
          createSmallSizePreview(root), "silhouette-lock small-size proof", outputs);
      writeOutput(root, proofRoot + "get_ready_notification_preview.png",
          createNotificationPreview(masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_splash_preview.png",
          createSplashPreview(root, masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "get_ready_wordmark_preview.png",
          createWordmarkPreview(masters), "generated proof composite", outputs);
      writeOutput(root, proofRoot + "old_vs_new_brand_comparison.png",
          createOldVsNewComparison(masters), "generated proof composite", outputs);

      writeOutput(root, proofRoot + "get_ready_same_scale_comparison.png",
          createSameScaleComparison(reference, masters),
          APPROVED_REFERENCE_RELATIVE + "#normalized-primary-mark-vs-vector", outputs);
      writeOutput(root, proofRoot + "get_ready_reference_vector_overlay.png",
          createReferenceVectorOverlay(reference, masters),
          APPROVED_REFERENCE_RELATIVE + "#normalized-magenta-cyan-overlay", outputs);
      writeOutput(root, proofRoot + "get_ready_landmark_comparison.png",
          createLandmarkComparison(reference, masters),
          APPROVED_REFERENCE_RELATIVE + "#normalized-landmark-audit", outputs);
      writeOutput(root, proofRoot + "get_ready_geometry_before_after.png",
          createSameScaleComparison(reference, masters),
          APPROVED_REFERENCE_RELATIVE + "#same-scale-silhouette-comparison", outputs);
    } finally {
      reference.flush();
    }
  }

  private static BufferedImage renderSvg(
      SvgDocument svg,
      int width,
      int height,
      Theme theme,
      MaskKind mask,
      Color forcedBackground) {
    validateOutputAspect(svg, width, height);
    int highWidth = Math.multiplyExact(width, SUPERSAMPLE);
    int highHeight = Math.multiplyExact(height, SUPERSAMPLE);

    BufferedImage high = createSrgbImage(highWidth, highHeight);
    Graphics2D graphics = high.createGraphics();
    try {
      configureVectorGraphics(graphics);
      graphics.setComposite(AlphaComposite.Src);
      graphics.setColor(new Color(0, 0, 0, 0));
      graphics.fillRect(0, 0, highWidth, highHeight);
      graphics.setComposite(AlphaComposite.SrcOver);

      double scaleX = highWidth / svg.viewWidth();
      double scaleY = highHeight / svg.viewHeight();
      graphics.scale(scaleX, scaleY);
      graphics.translate(-svg.viewX(), -svg.viewY());

      Shape clip = maskShape(svg, mask);
      if (clip != null) {
        graphics.clip(clip);
      }
      if (forcedBackground != null) {
        graphics.setColor(forcedBackground);
        graphics.fill(new Rectangle2D.Double(
            svg.viewX(), svg.viewY(), svg.viewWidth(), svg.viewHeight()));
      }
      drawChildren(graphics, svg.document().getDocumentElement(), theme, svg.path());
    } finally {
      graphics.dispose();
    }

    BufferedImage result = createSrgbImage(width, height);
    Graphics2D downsample = result.createGraphics();
    try {
      configureDownsampleGraphics(downsample);
      downsample.setComposite(AlphaComposite.Src);
      downsample.drawImage(high, 0, 0, width, height, null);
    } finally {
      downsample.dispose();
      high.flush();
    }
    clearTransparentRgb(result);
    return result;
  }

  private static Shape maskShape(SvgDocument svg, MaskKind mask) {
    if (mask == MaskKind.NONE) {
      return null;
    }
    if (Math.abs(svg.viewWidth() - svg.viewHeight()) > 0.001) {
      throw new IllegalArgumentException("Masks require a square SVG viewBox: " + svg.path());
    }
    if (mask == MaskKind.CIRCLE) {
      return new Ellipse2D.Double(
          svg.viewX(), svg.viewY(), svg.viewWidth(), svg.viewHeight());
    }
    return createSquircle(
        svg.viewX(), svg.viewY(), svg.viewWidth(), svg.viewHeight());
  }

  private static Shape createSquircle(double x, double y, double width, double height) {
    Path2D.Double path = new Path2D.Double();
    double centerX = x + width / 2.0;
    double centerY = y + height / 2.0;
    double radiusX = width / 2.0;
    double radiusY = height / 2.0;
    int points = 256;
    for (int index = 0; index <= points; index++) {
      double angle = 2.0 * Math.PI * index / points;
      double cosine = Math.cos(angle);
      double sine = Math.sin(angle);
      double px = centerX + radiusX * Math.copySign(Math.sqrt(Math.abs(cosine)), cosine);
      double py = centerY + radiusY * Math.copySign(Math.sqrt(Math.abs(sine)), sine);
      if (index == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.closePath();
    return path;
  }

  private static void drawChildren(
      Graphics2D graphics, Element parent, Theme theme, Path source) {
    NodeList children = parent.getChildNodes();
    for (int index = 0; index < children.getLength(); index++) {
      Node node = children.item(index);
      if (node.getNodeType() != Node.ELEMENT_NODE) {
        continue;
      }
      Element element = (Element) node;
      switch (elementName(element)) {
        case "g" -> drawChildren(graphics, element, theme, source);
        case "rect" -> drawRect(graphics, element, theme, source);
        case "circle" -> drawCircle(graphics, element, theme, source);
        case "path" -> drawPath(graphics, element, theme, source);
        case "text" -> drawText(graphics, element, theme, source);
        case "title", "desc" -> {
          // Accessibility metadata is intentionally not rendered.
        }
        default -> throw new IllegalArgumentException(
            "Unsupported SVG element reached renderer: " + elementName(element));
      }
    }
  }

  private static void drawRect(
      Graphics2D graphics, Element element, Theme theme, Path source) {
    double x = number(element, "x", 0.0, source);
    double y = number(element, "y", 0.0, source);
    double width = number(element, "width", Double.NaN, source);
    double height = number(element, "height", Double.NaN, source);
    double radiusX = number(element, "rx", 0.0, source);
    double radiusY = element.hasAttribute("ry")
        ? number(element, "ry", radiusX, source)
        : radiusX;
    if (!(width > 0.0) || !(height > 0.0) || radiusX < 0.0 || radiusY < 0.0) {
      throw new IllegalArgumentException("Invalid <rect> geometry in " + source);
    }
    radiusX = Math.min(radiusX, width / 2.0);
    radiusY = Math.min(radiusY, height / 2.0);

    Color color = elementColor(element, theme, source);
    float opacity = elementOpacity(element, source);
    Composite previous = graphics.getComposite();
    graphics.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, opacity));
    graphics.setColor(color);
    if (radiusX == 0.0 && radiusY == 0.0) {
      graphics.fill(new Rectangle2D.Double(x, y, width, height));
    } else {
      graphics.fill(new RoundRectangle2D.Double(
          x, y, width, height, radiusX * 2.0, radiusY * 2.0));
    }
    graphics.setComposite(previous);
  }

  private static void drawCircle(
      Graphics2D graphics, Element element, Theme theme, Path source) {
    double centerX = number(element, "cx", Double.NaN, source);
    double centerY = number(element, "cy", Double.NaN, source);
    double radius = number(element, "r", Double.NaN, source);
    if (!Double.isFinite(centerX) || !Double.isFinite(centerY) || !(radius > 0.0)) {
      throw new IllegalArgumentException("Invalid <circle> geometry in " + source);
    }

    Composite previous = graphics.getComposite();
    graphics.setComposite(AlphaComposite.getInstance(
        AlphaComposite.SRC_OVER, elementOpacity(element, source)));
    graphics.setColor(elementColor(element, theme, source));
    graphics.fill(new Ellipse2D.Double(
        centerX - radius, centerY - radius, radius * 2.0, radius * 2.0));
    graphics.setComposite(previous);
  }

  private static void drawPath(
      Graphics2D graphics, Element element, Theme theme, Path source) {
    Path2D.Double path = parseSvgPath(requireAttribute(element, "d"), source);
    String fill = element.hasAttribute("fill") ? element.getAttribute("fill").trim() : "none";
    String stroke = element.hasAttribute("stroke")
        ? element.getAttribute("stroke").trim()
        : "none";

    Composite previousComposite = graphics.getComposite();
    java.awt.Stroke previousStroke = graphics.getStroke();
    graphics.setComposite(AlphaComposite.getInstance(
        AlphaComposite.SRC_OVER, elementOpacity(element, source)));
    if (!"none".equalsIgnoreCase(fill)) {
      graphics.setColor(elementPaintColor(element, theme, "fill", source));
      graphics.fill(path);
    }
    if (!"none".equalsIgnoreCase(stroke)) {
      float width = (float) number(element, "stroke-width", Double.NaN, source);
      int cap = "round".equals(element.getAttribute("stroke-linecap").trim())
          ? BasicStroke.CAP_ROUND
          : BasicStroke.CAP_BUTT;
      graphics.setStroke(new BasicStroke(width, cap, BasicStroke.JOIN_ROUND));
      graphics.setColor(elementPaintColor(element, theme, "stroke", source));
      graphics.draw(path);
    }
    graphics.setStroke(previousStroke);
    graphics.setComposite(previousComposite);
  }

  private static Path2D.Double parseSvgPath(String data, Path source) {
    List<String> tokens = new ArrayList<>();
    Matcher matcher = PATH_TOKEN.matcher(data);
    int consumed = 0;
    while (matcher.find()) {
      String skipped = data.substring(consumed, matcher.start());
      if (!skipped.matches("[\\s,]*")) {
        throw new IllegalArgumentException("Unsupported SVG path syntax in " + source + ": " + skipped);
      }
      tokens.add(matcher.group());
      consumed = matcher.end();
    }
    if (!data.substring(consumed).matches("[\\s,]*") || tokens.isEmpty()) {
      throw new IllegalArgumentException("Unsupported SVG path syntax in " + source);
    }

    Path2D.Double path = new Path2D.Double(Path2D.WIND_NON_ZERO);
    int index = 0;
    boolean moved = false;
    while (index < tokens.size()) {
      String command = tokens.get(index++);
      if (command.length() != 1 || !Character.isLetter(command.charAt(0))) {
        throw new IllegalArgumentException(
            "Every controlled path segment needs an explicit command in " + source);
      }
      switch (command.charAt(0)) {
        case 'M' -> {
          double x = pathNumber(tokens, index++, source);
          double y = pathNumber(tokens, index++, source);
          path.moveTo(x, y);
          moved = true;
        }
        case 'L' -> {
          requirePathMove(moved, source);
          double x = pathNumber(tokens, index++, source);
          double y = pathNumber(tokens, index++, source);
          path.lineTo(x, y);
        }
        case 'C' -> {
          requirePathMove(moved, source);
          double x1 = pathNumber(tokens, index++, source);
          double y1 = pathNumber(tokens, index++, source);
          double x2 = pathNumber(tokens, index++, source);
          double y2 = pathNumber(tokens, index++, source);
          double x = pathNumber(tokens, index++, source);
          double y = pathNumber(tokens, index++, source);
          path.curveTo(x1, y1, x2, y2, x, y);
        }
        case 'Z' -> {
          requirePathMove(moved, source);
          path.closePath();
        }
        default -> throw new IllegalArgumentException(
            "Only absolute M, L, C, and Z path commands are supported in " + source
                + ": " + command);
      }
    }
    return path;
  }

  private static double pathNumber(List<String> tokens, int index, Path source) {
    if (index >= tokens.size() || (tokens.get(index).length() == 1
        && Character.isLetter(tokens.get(index).charAt(0)))) {
      throw new IllegalArgumentException("Incomplete SVG path data in " + source);
    }
    double value;
    try {
      value = Double.parseDouble(tokens.get(index));
    } catch (NumberFormatException exception) {
      throw new IllegalArgumentException("Invalid SVG path number in " + source, exception);
    }
    if (!Double.isFinite(value)) {
      throw new IllegalArgumentException("Non-finite SVG path number in " + source);
    }
    return value;
  }

  private static void requirePathMove(boolean moved, Path source) {
    if (!moved) {
      throw new IllegalArgumentException("SVG path must begin with M in " + source);
    }
  }

  private static void drawText(
      Graphics2D graphics, Element element, Theme theme, Path source) {
    String text = element.getTextContent().strip();
    if (text.isEmpty()) {
      return;
    }
    if (element.getElementsByTagNameNS("*", "*").getLength() > 0) {
      throw new IllegalArgumentException("Nested text markup is unsupported in " + source);
    }

    double x = number(element, "x", 0.0, source);
    double y = number(element, "y", 0.0, source);
    float size = (float) number(element, "font-size", Double.NaN, source);
    int weight = (int) Math.round(number(element, "font-weight", 400.0, source));
    String families = requireAttribute(element, "font-family");
    Font font = chooseInstalledFont(families, text, size, weight, source);

    FontRenderContext context = graphics.getFontRenderContext();
    TextLayout layout = new TextLayout(text, font, context);
    double drawX = x;
    String anchor = element.getAttribute("text-anchor").trim();
    if ("middle".equals(anchor)) {
      drawX -= layout.getAdvance() / 2.0;
    } else if ("end".equals(anchor)) {
      drawX -= layout.getAdvance();
    } else if (!anchor.isEmpty() && !"start".equals(anchor)) {
      throw new IllegalArgumentException("Unsupported text-anchor in " + source + ": " + anchor);
    }

    double baseline = y;
    String dominantBaseline = element.getAttribute("dominant-baseline").trim();
    if ("hanging".equals(dominantBaseline)) {
      LineMetrics metrics = font.getLineMetrics(text, context);
      baseline += metrics.getAscent();
    } else if (!dominantBaseline.isEmpty() && !"alphabetic".equals(dominantBaseline)) {
      throw new IllegalArgumentException(
          "Unsupported dominant-baseline in " + source + ": " + dominantBaseline);
    }

    Composite previous = graphics.getComposite();
    graphics.setComposite(AlphaComposite.getInstance(
        AlphaComposite.SRC_OVER, elementOpacity(element, source)));
    graphics.setColor(elementColor(element, theme, source));
    graphics.setFont(font);
    graphics.drawString(text, (float) drawX, (float) baseline);
    graphics.setComposite(previous);
  }

  private static Font chooseInstalledFont(
      String familyList, String text, float size, int weight, Path source) {
    List<String> attempted = new ArrayList<>();
    for (String rawFamily : familyList.split(",")) {
      String requested = stripQuotes(rawFamily.trim());
      if (requested.isEmpty()) {
        continue;
      }
      String normalized = normalizeLogicalFont(requested);
      String installed = AVAILABLE_FONTS.get(normalized.toLowerCase(Locale.ROOT));
      if (installed == null) {
        attempted.add(requested + " (not installed)");
        continue;
      }
      Font font = createWeightedFont(installed, size, weight);
      int unsupportedIndex = font.canDisplayUpTo(text);
      if (unsupportedIndex >= 0) {
        attempted.add(installed + " (missing U+"
            + Integer.toHexString(text.codePointAt(unsupportedIndex)).toUpperCase(Locale.ROOT) + ")");
        continue;
      }
      USED_FONTS.add(installed);
      return font;
    }
    throw new IllegalArgumentException(
        "No installed system font can render text in " + source + ". Tried: " + attempted);
  }

  private static Font createWeightedFont(String family, float size, int numericWeight) {
    Map<AttributedCharacterIterator.Attribute, Object> attributes = new HashMap<>();
    attributes.put(TextAttribute.FAMILY, family);
    attributes.put(TextAttribute.SIZE, size);
    attributes.put(TextAttribute.WEIGHT, awtWeight(numericWeight));
    return new Font(attributes);
  }

  private static float awtWeight(int weight) {
    if (weight <= 200) {
      return TextAttribute.WEIGHT_EXTRA_LIGHT;
    }
    if (weight <= 300) {
      return TextAttribute.WEIGHT_LIGHT;
    }
    if (weight <= 450) {
      return TextAttribute.WEIGHT_REGULAR;
    }
    if (weight <= 550) {
      return TextAttribute.WEIGHT_MEDIUM;
    }
    if (weight <= 650) {
      return TextAttribute.WEIGHT_SEMIBOLD;
    }
    if (weight <= 750) {
      return TextAttribute.WEIGHT_BOLD;
    }
    if (weight <= 850) {
      return TextAttribute.WEIGHT_EXTRABOLD;
    }
    return TextAttribute.WEIGHT_ULTRABOLD;
  }

  private static String normalizeLogicalFont(String requested) {
    return switch (requested.toLowerCase(Locale.ROOT)) {
      case "sans-serif", "sans serif" -> Font.SANS_SERIF;
      case "serif" -> Font.SERIF;
      case "monospace", "monospaced" -> Font.MONOSPACED;
      case "dialog" -> Font.DIALOG;
      case "dialoginput", "dialog input" -> Font.DIALOG_INPUT;
      default -> requested;
    };
  }

  private static Map<String, String> loadAvailableFonts() {
    Map<String, String> fonts = new HashMap<>();
    for (String family : GraphicsEnvironment
        .getLocalGraphicsEnvironment()
        .getAvailableFontFamilyNames(Locale.ROOT)) {
      fonts.putIfAbsent(family.toLowerCase(Locale.ROOT), family);
    }
    for (String logical : List.of(
        Font.SANS_SERIF, Font.SERIF, Font.MONOSPACED, Font.DIALOG, Font.DIALOG_INPUT)) {
      fonts.putIfAbsent(logical.toLowerCase(Locale.ROOT), logical);
    }
    return fonts;
  }

  private static Color elementColor(Element element, Theme theme, Path source) {
    return elementPaintColor(element, theme, "fill", source);
  }

  private static Color elementPaintColor(
      Element element, Theme theme, String paint, Path source) {
    String lightAttribute = "data-light-" + paint;
    String attribute = theme == Theme.LIGHT && element.hasAttribute(lightAttribute)
        ? element.getAttribute(lightAttribute)
        : element.getAttribute(paint);
    return parseSvgColor(attribute, source);
  }

  private static Color parseSvgColor(String value, Path source) {
    String trimmed = value.trim();
    if (!trimmed.matches("#[0-9A-Fa-f]{6}")) {
      throw new IllegalArgumentException(
          "Only explicit #RRGGBB fills are allowed in " + source + ": " + value);
    }
    return rgb(trimmed.substring(1));
  }

  private static float elementOpacity(Element element, Path source) {
    if (!element.hasAttribute("opacity")) {
      return 1.0f;
    }
    double value = number(element, "opacity", 1.0, source);
    if (value < 0.0 || value > 1.0) {
      throw new IllegalArgumentException("Opacity outside 0..1 in " + source);
    }
    return (float) value;
  }

  private static void validateOutputAspect(SvgDocument svg, int width, int height) {
    if (width <= 0 || height <= 0) {
      throw new IllegalArgumentException("PNG dimensions must be positive");
    }
    double sourceRatio = svg.viewWidth() / svg.viewHeight();
    double outputRatio = (double) width / height;
    if (Math.abs(sourceRatio - outputRatio) > 0.000001) {
      throw new IllegalArgumentException(
          "Output aspect ratio would distort " + svg.path() + ": " + width + "x" + height);
    }
  }

  private static BufferedImage createContactSheet(Map<String, SvgDocument> masters) {
    BufferedImage sheet = createSheet(2400, 1600, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    List<BufferedImage> temporary = new ArrayList<>();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready master contact sheet", 70, 95, OFF_WHITE);
      proofText(graphics, "Open arc · readiness signal · approved flat colors · no board cropping", 70, 135,
          24, 400, MUTED_TEXT);

      int panelY = 175;
      int panelWidth = 540;
      int panelHeight = 540;
      int[] panelX = {60, 630, 1200, 1770};
      Color[] backgrounds = {DEEP_GRAY_BLUE, DEEP_SPACE_BLACK, OFF_WHITE, DEEP_SPACE_BLACK};
      String[] labels = {"Primary launcher", "Mark on dark", "Mark on light", "Monochrome"};
      String[] masterKeys = {"mark", "markDark", "markLight", "markMonochrome"};
      Theme[] themes = {Theme.DEFAULT, Theme.DEFAULT, Theme.DEFAULT, Theme.DEFAULT};
      for (int index = 0; index < panelX.length; index++) {
        proofPanel(graphics, panelX[index], panelY, panelWidth, panelHeight, backgrounds[index]);
        Color labelColor = index == 2 ? DEEP_SPACE_BLACK : OFF_WHITE;
        proofText(graphics, labels[index], panelX[index] + 28, panelY + 48,
            27, 600, labelColor);
        BufferedImage image = renderSvg(masters.get(masterKeys[index]), 400, 400,
            themes[index], MaskKind.NONE, null);
        temporary.add(image);
        drawImageFit(graphics, image,
            panelX[index] + 70, panelY + 80, 400, 400, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
      }

      proofPanel(graphics, 60, 760, 1430, 700, DEEP_SPACE_BLACK);
      proofText(graphics, "Horizontal wordmark", 95, 815, 29, 600, OFF_WHITE);
      BufferedImage horizontal = renderSvg(
          masters.get("wordmarkHorizontal"), 1280, 320, Theme.DEFAULT, MaskKind.NONE, null);
      temporary.add(horizontal);
      drawImageFit(graphics, horizontal, 110, 905, 1320, 330,
          RenderingHints.VALUE_INTERPOLATION_BICUBIC);
      proofText(graphics, "Get in #F6F7F8 · Ready in #16A34A · visible space preserved", 110, 1375,
          24, 400, MUTED_TEXT);

      proofPanel(graphics, 1530, 760, 810, 700, DEEP_SPACE_BLACK);
      proofText(graphics, "Vertical combination", 1565, 815, 29, 600, OFF_WHITE);
      BufferedImage vertical = renderSvg(
          masters.get("logoVertical"), 480, 600, Theme.DEFAULT, MaskKind.NONE, null);
      temporary.add(vertical);
      drawImageFit(graphics, vertical, 1695, 830, 480, 600,
          RenderingHints.VALUE_INTERPOLATION_BICUBIC);

      proofText(graphics,
          "Asymmetric Bézier · arc frame 525×605 · stroke 80 · bar 225×75 · dot 150 · W/D 1.50",
          70, 1545, 23, 400, MUTED_TEXT);
    } finally {
      graphics.dispose();
      temporary.forEach(BufferedImage::flush);
    }
    return sheet;
  }

  private static BufferedImage createLauncherMaskPreview(Map<String, SvgDocument> masters) {
    BufferedImage sheet = createSheet(2200, 780, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    List<BufferedImage> temporary = new ArrayList<>();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready launcher mask preview", 65, 90, OFF_WHITE);
      proofText(graphics,
          "Adaptive previews use a separate #111111 background and transparent foreground mark.",
          65, 130, 23, 400, MUTED_TEXT);

      int[] x = {60, 590, 1120, 1650};
      String[] labels = {
          "Launcher PNG", "Round resource", "Adaptive circle mask", "Adaptive squircle mask"
      };
      for (int index = 0; index < x.length; index++) {
        proofPanel(graphics, x[index], 170, 480, 540, DEEP_SPACE_BLACK);
        proofText(graphics, labels[index], x[index] + 25, 215, 25, 600, OFF_WHITE);
      }

      BufferedImage launcher = renderSvg(
          masters.get("mark"), 400, 400, Theme.DEFAULT, MaskKind.NONE, null);
      BufferedImage round = renderSvg(
          masters.get("mark"), 400, 400, Theme.DEFAULT, MaskKind.CIRCLE, null);
      BufferedImage circle = renderSvg(
          masters.get("markDark"), 400, 400, Theme.DEFAULT, MaskKind.CIRCLE, DEEP_SPACE_BLACK);
      BufferedImage squircle = renderSvg(
          masters.get("markDark"), 400, 400, Theme.DEFAULT, MaskKind.SQUIRCLE, DEEP_SPACE_BLACK);
      temporary.addAll(List.of(launcher, round, circle, squircle));

      BufferedImage[] images = {launcher, round, circle, squircle};
      for (int index = 0; index < images.length; index++) {
        int imageX = x[index] + 40;
        int imageY = 250;
        graphics.drawImage(images[index], imageX, imageY, null);
        drawSafeAreaOverlay(graphics, imageX, imageY, 400);
      }
      proofText(graphics, "Dashed square = conservative adaptive safe-area guide", 65, 755,
          22, 400, MUTED_TEXT);
    } finally {
      graphics.dispose();
      temporary.forEach(BufferedImage::flush);
    }
    return sheet;
  }

  private static BufferedImage createSmallSizePreview(Path root) throws IOException {
    int[] sizes = {1024, 512, 256, 128, 64, 32, 24, 16};
    BufferedImage[] images = new BufferedImage[sizes.length];
    for (int index = 0; index < sizes.length; index++) {
      int size = sizes[index];
      Path path;
      path = root.resolve("assets/branding/generated/get_ready_mark_" + size + ".png");
      images[index] = requireImage(path);
    }

    BufferedImage sheet = createSheet(2304, 1900, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready small-size preview", 36, 78, OFF_WHITE);
      proofText(graphics,
          "Every icon below is shown at its exact 1:1 pixel dimension.",
          36, 118, 23, 400, MUTED_TEXT);

      int x = 36;
      int baseline = 1210;
      for (int index = 0; index < sizes.length; index++) {
        int size = sizes[index];
        graphics.drawImage(images[index], x, baseline - size, null);
        int labelY = 1260 + Math.max(0, index - 3) * 42;
        int labelX = Math.min(x, 2235);
        proofText(graphics, size + " px", labelX, labelY, size <= 64 ? 20 : 23,
            600, OFF_WHITE);
        x += size + 28;
      }

      proofText(graphics, "Pixel-level diagnostic (nearest-neighbor enlargement)",
          36, 1500, 25, 600, OFF_WHITE);
      drawNearestNeighbor(graphics, images[5], 40, 1530, 256, 256);
      drawNearestNeighbor(graphics, images[6], 350, 1530, 192, 192);
      drawNearestNeighbor(graphics, images[7], 600, 1530, 160, 160);
      proofText(graphics, "32 px ×8", 40, 1825, 21, 400, MUTED_TEXT);
      proofText(graphics, "24 px ×8", 350, 1765, 21, 400, MUTED_TEXT);
      proofText(graphics, "16 px ×10", 600, 1725, 21, 400, MUTED_TEXT);
      proofText(graphics,
          "All eight sizes are production sRGB PNGs generated directly from the corrected SVG master.",
          850, 1600, 23, 400, MUTED_TEXT);
    } finally {
      graphics.dispose();
      for (BufferedImage image : images) {
        image.flush();
      }
    }
    return sheet;
  }

  private static BufferedImage createDarkLightPreview(Map<String, SvgDocument> masters) {
    BufferedImage sheet = createSheet(2200, 1100, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    List<BufferedImage> temporary = new ArrayList<>();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready dark / light preview", 65, 90, OFF_WHITE);
      proofText(graphics, "Exact production surface colors shown without gradients or texture.",
          65, 130, 23, 400, MUTED_TEXT);

      proofPanel(graphics, 60, 170, 1010, 850, DEEP_SPACE_BLACK);
      proofPanel(graphics, 1130, 170, 1010, 850, OFF_WHITE);
      proofText(graphics, "Dark surface · #111111", 95, 225, 28, 600, OFF_WHITE);
      proofText(graphics, "Light surface · #F6F7F8", 1165, 225, 28, 600, DEEP_SPACE_BLACK);

      BufferedImage horizontalDark = renderSvg(
          masters.get("wordmarkHorizontal"), 880, 220, Theme.DEFAULT, MaskKind.NONE, null);
      BufferedImage horizontalLight = renderSvg(
          masters.get("wordmarkHorizontal"), 880, 220, Theme.LIGHT, MaskKind.NONE, null);
      BufferedImage verticalDark = renderSvg(
          masters.get("logoVertical"), 500, 625, Theme.DEFAULT, MaskKind.NONE, null);
      BufferedImage verticalLight = renderSvg(
          masters.get("logoVertical"), 500, 625, Theme.LIGHT, MaskKind.NONE, null);
      temporary.addAll(List.of(horizontalDark, horizontalLight, verticalDark, verticalLight));

      graphics.drawImage(horizontalDark, 125, 285, null);
      graphics.drawImage(horizontalLight, 1195, 285, null);
      graphics.drawImage(verticalDark, 315, 405, null);
      graphics.drawImage(verticalLight, 1385, 405, null);
      proofText(graphics, "Get = off-white · Ready = brand green", 95, 990,
          22, 400, MUTED_TEXT);
      proofText(graphics, "Get = ink black · Ready = brand green", 1165, 990,
          22, 400, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      temporary.forEach(BufferedImage::flush);
    }
    return sheet;
  }

  private static BufferedImage createNotificationPreview(Map<String, SvgDocument> masters) {
    BufferedImage icon = renderSvg(
        masters.get("notification"), 24, 24, Theme.DEFAULT, MaskKind.NONE, null);
    BufferedImage inverse = tintAlpha(icon, DEEP_SPACE_BLACK);
    BufferedImage sheet = createSheet(1800, 900, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready notification preview", 60, 90, OFF_WHITE);
      proofText(graphics,
          "Production resource: transparent background, one solid monochrome alpha silhouette.",
          60, 130, 23, 400, MUTED_TEXT);

      proofPanel(graphics, 60, 170, 720, 150, DEEP_SPACE_BLACK);
      proofText(graphics, "9:41", 95, 225, 22, 600, OFF_WHITE);
      graphics.drawImage(icon, 690, 205, null);
      proofText(graphics, "Actual 24×24 px status-bar scale", 95, 285, 21, 400, MUTED_TEXT);

      proofPanel(graphics, 60, 350, 720, 300, DEEP_SPACE_BLACK);
      proofPanel(graphics, 95, 405, 650, 170, DEEP_GRAY_BLUE);
      drawImageFit(graphics, icon, 125, 435, 72, 72,
          RenderingHints.VALUE_INTERPOLATION_BICUBIC);
      proofText(graphics, "Get Ready", 225, 455, 29, 600, OFF_WHITE);
      proofText(graphics, "随时准备，迎接每一次机会。", 225, 500, 22, 400, MUTED_TEXT);
      proofText(graphics, "Simulated notification card · preview only", 95, 620,
          21, 400, MUTED_TEXT);

      proofPanel(graphics, 840, 170, 420, 600, DEEP_SPACE_BLACK);
      proofText(graphics, "Alpha form ×14", 875, 220, 25, 600, OFF_WHITE);
      drawNearestNeighbor(graphics, icon, 882, 270, 336, 336);
      drawPixelGrid(graphics, 882, 270, 24, 14);

      proofPanel(graphics, 1320, 170, 420, 600, OFF_WHITE);
      proofText(graphics, "Inverse diagnostic", 1355, 220, 25, 600, DEEP_SPACE_BLACK);
      drawNearestNeighbor(graphics, inverse, 1362, 270, 336, 336);
      drawPixelGrid(graphics, 1362, 270, 24, 14);
      proofText(graphics, "Not an Android resource", 1355, 700, 21, 400, DEEP_GRAY_BLUE);

      proofText(graphics,
          "24×24 viewport · W/D 1.50 · H/D 0.50 · gap/D 0.30 · no background, green, or shadow",
          60, 845, 23, 400, MUTED_TEXT);
    } finally {
      graphics.dispose();
      icon.flush();
      inverse.flush();
    }
    return sheet;
  }

  private static BufferedImage createSplashPreview(
      Path root, Map<String, SvgDocument> masters) throws IOException {
    BufferedImage splashDark = requireImage(
        root.resolve("assets/branding/generated/get_ready_splash_dark.png"));
    BufferedImage splashLight = requireImage(
        root.resolve("assets/branding/generated/get_ready_splash_light.png"));
    BufferedImage splashBrand = requireImage(
        root.resolve("android/app/src/main/res/drawable-nodpi/getready_splash_brand.png"));
    BufferedImage mark;
    try {
      mark = renderSvg(masters.get("markDark"), 320, 320,
          Theme.DEFAULT, MaskKind.NONE, null);
    } catch (Exception exception) {
      throw new IOException("Unable to render splash proof mark", exception);
    }

    BufferedImage legacy = createSrgbImage(720, 1280);
    Graphics2D legacyGraphics = legacy.createGraphics();
    try {
      configureProofGraphics(legacyGraphics);
      legacyGraphics.setColor(DEEP_SPACE_BLACK);
      legacyGraphics.fillRect(0, 0, 720, 1280);
      drawImageFit(legacyGraphics, splashBrand, 180, 300, 360, 450,
          RenderingHints.VALUE_INTERPOLATION_BICUBIC);
    } finally {
      legacyGraphics.dispose();
    }

    BufferedImage androidTwelve = createSrgbImage(720, 1280);
    Graphics2D androidGraphics = androidTwelve.createGraphics();
    try {
      configureProofGraphics(androidGraphics);
      androidGraphics.setColor(DEEP_SPACE_BLACK);
      androidGraphics.fillRect(0, 0, 720, 1280);
      androidGraphics.drawImage(mark, 200, 380, null);
    } finally {
      androidGraphics.dispose();
    }

    BufferedImage sheet = createSheet(2200, 1400, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready splash preview", 65, 90, OFF_WHITE);
      proofText(graphics,
          "Native startup stays static and immediate; Android 12+ uses the mark-only platform treatment.",
          65, 130, 23, 400, MUTED_TEXT);

      BufferedImage[] screens = {legacy, androidTwelve, splashDark, splashLight};
      String[] labels = {
          "Legacy native", "Android 12+ mark only", "Full dark composition", "Full light composition"
      };
      int[] x = {80, 610, 1140, 1670};
      for (int index = 0; index < screens.length; index++) {
        proofText(graphics, labels[index], x[index], 205, 25, 600, OFF_WHITE);
        drawPhoneFrame(graphics, screens[index], x[index], 245, 400, 900);
      }
      proofText(graphics,
          "No progress bar · no artificial delay · Android 12 omits wordmark and tagline",
          65, 1325, 23, 400, MUTED_TEXT);
    } finally {
      graphics.dispose();
      splashDark.flush();
      splashLight.flush();
      splashBrand.flush();
      mark.flush();
      legacy.flush();
      androidTwelve.flush();
    }
    return sheet;
  }

  private static BufferedImage createWordmarkPreview(Map<String, SvgDocument> masters) {
    BufferedImage sheet = createSheet(2200, 1200, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    List<BufferedImage> temporary = new ArrayList<>();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready wordmark preview", 65, 90, OFF_WHITE);
      proofText(graphics,
          "Exact casing and spacing: Get Ready · neutral Get · green Ready",
          65, 130, 23, 400, MUTED_TEXT);

      proofPanel(graphics, 60, 170, 1010, 940, DEEP_SPACE_BLACK);
      proofPanel(graphics, 1130, 170, 1010, 940, OFF_WHITE);
      proofText(graphics, "Dark surface", 95, 225, 28, 600, OFF_WHITE);
      proofText(graphics, "Light surface", 1165, 225, 28, 600, DEEP_SPACE_BLACK);

      BufferedImage horizontalDark = renderSvg(
          masters.get("wordmarkHorizontal"), 880, 220, Theme.DEFAULT, MaskKind.NONE, null);
      BufferedImage horizontalLight = renderSvg(
          masters.get("wordmarkHorizontal"), 880, 220, Theme.LIGHT, MaskKind.NONE, null);
      BufferedImage verticalDark = renderSvg(
          masters.get("logoVertical"), 440, 550, Theme.DEFAULT, MaskKind.NONE, null);
      BufferedImage verticalLight = renderSvg(
          masters.get("logoVertical"), 440, 550, Theme.LIGHT, MaskKind.NONE, null);
      temporary.addAll(List.of(horizontalDark, horizontalLight, verticalDark, verticalLight));

      graphics.drawImage(horizontalDark, 125, 285, null);
      graphics.drawImage(horizontalLight, 1195, 285, null);
      graphics.drawImage(verticalDark, 345, 485, null);
      graphics.drawImage(verticalLight, 1415, 485, null);
      proofText(graphics, "随时准备，迎接每一次机会。", 315, 1065,
          26, 500, MUTED_TEXT);
      proofText(graphics, "随时准备，迎接每一次机会。", 1385, 1065,
          26, 500, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      temporary.forEach(BufferedImage::flush);
    }
    return sheet;
  }

  private static BufferedImage createOldVsNewComparison(
      Map<String, SvgDocument> masters) {
    BufferedImage sheet = createSheet(2200, 1100, DEEP_GRAY_BLUE);
    Graphics2D graphics = sheet.createGraphics();
    BufferedImage newMark = null;
    BufferedImage newWordmark = null;
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Old vs new brand comparison", 65, 90, OFF_WHITE);
      proofText(graphics,
          "Historical P10 artwork appears only in this comparison proof.",
          65, 130, 23, 400, MUTED_TEXT);

      Color oldBlack = rgb("0D1117");
      Color oldGreen = rgb("22C55E");
      Color oldWhite = rgb("F1F3F5");
      proofPanel(graphics, 60, 170, 1010, 840, oldBlack);
      proofPanel(graphics, 1130, 170, 1010, 840, OFF_WHITE);
      proofText(graphics, "Previous P10", 95, 225, 28, 600, oldWhite);
      proofText(graphics, "Approved Get Ready 2.6", 1165, 225, 28, 600,
          DEEP_SPACE_BLACK);

      drawOldThreeStep(graphics, 315, 255, 500, oldWhite, oldGreen);
      proofText(graphics, "get", 315, 850, 118, 600, oldWhite);
      proofText(graphics, "ready", 500, 850, 118, 600, oldGreen);
      proofText(graphics, "Three-step mark · lowercase getready", 260, 945,
          24, 400, rgb("AAB1BC"));

      newMark = renderSvg(masters.get("mark"), 500, 500,
          Theme.DEFAULT, MaskKind.NONE, null);
      newWordmark = renderSvg(masters.get("wordmarkHorizontal"), 880, 220,
          Theme.LIGHT, MaskKind.NONE, null);
      graphics.drawImage(newMark, 1385, 255, null);
      graphics.drawImage(newWordmark, 1195, 755, null);
      proofText(graphics, "Open arc + status bar + dot · exact Get Ready", 1280, 965,
          24, 400, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      if (newMark != null) {
        newMark.flush();
      }
      if (newWordmark != null) {
        newWordmark.flush();
      }
    }
    return sheet;
  }

  private static BufferedImage loadApprovedReference(Path root) throws IOException {
    Path referencePath = root.resolve(APPROVED_REFERENCE_RELATIVE).normalize();
    if (!Files.isRegularFile(referencePath)) {
      throw new IOException("Missing approved geometry reference board: " + referencePath);
    }
    byte[] referenceBytes = Files.readAllBytes(referencePath);
    String referenceHash = sha256(referenceBytes);
    if (!APPROVED_REFERENCE_SHA256.equals(referenceHash)) {
      throw new IOException(
          "Approved geometry reference SHA-256 mismatch: expected "
              + APPROVED_REFERENCE_SHA256 + ", found " + referenceHash);
    }

    BufferedImage reference = requireImage(referencePath);
    if (reference.getWidth() != 1448 || reference.getHeight() != 1086) {
      reference.flush();
      throw new IOException(
          "Approved geometry reference dimensions changed: expected 1448x1086");
    }
    return reference;
  }

  private static BufferedImage createReferenceCrop(
      BufferedImage reference, int x, int y, int width, int height, int scale) {
    if (x < 0 || y < 0 || width <= 0 || height <= 0 || scale <= 0
        || x + width > reference.getWidth() || y + height > reference.getHeight()) {
      throw new IllegalArgumentException("Reference crop is outside the approved board");
    }
    BufferedImage crop = createSrgbImage(width * scale, height * scale);
    Graphics2D graphics = crop.createGraphics();
    try {
      configureDownsampleGraphics(graphics);
      graphics.setComposite(AlphaComposite.Src);
      graphics.drawImage(reference,
          0, 0, width * scale, height * scale,
          x, y, x + width, y + height,
          null);
    } finally {
      graphics.dispose();
    }
    return crop;
  }

  private static BufferedImage createReferenceSilhouette(BufferedImage reference) {
    int sourceX = 76;
    int sourceY = 97;
    int sourceWidth = 184;
    int sourceHeight = 187;
    BufferedImage classified = createSrgbImage(sourceWidth, sourceHeight);
    for (int y = 0; y < sourceHeight; y++) {
      for (int x = 0; x < sourceWidth; x++) {
        int rgb = reference.getRGB(sourceX + x, sourceY + y);
        int red = (rgb >>> 16) & 0xFF;
        int green = (rgb >>> 8) & 0xFF;
        int blue = rgb & 0xFF;
        int alpha;
        int flatRgb;
        if (green - red > 8 && green - blue > 8) {
          double alphaRed = (green - red) / 134.0;
          double alphaBlue = (green - blue) / 87.0;
          alpha = clampByte((int) Math.round(255.0 * (alphaRed + alphaBlue) / 2.0));
          flatRgb = TECHNOLOGY_GREEN.getRGB() & 0x00FFFFFF;
        } else {
          int range = Math.max(red, Math.max(green, blue))
              - Math.min(red, Math.min(green, blue));
          int luminance = (red * 54 + green * 183 + blue * 19) / 256;
          alpha = range <= 20
              ? clampByte((int) Math.round((252.0 - luminance) * 255.0 / 241.0))
              : 0;
          flatRgb = DEEP_SPACE_BLACK.getRGB() & 0x00FFFFFF;
        }
        if (alpha >= 5) {
          classified.setRGB(x, y, (alpha << 24) | flatRgb);
        }
      }
    }

    BufferedImage silhouette = createSrgbImage(1000, 1000);
    Graphics2D graphics = silhouette.createGraphics();
    try {
      configureDownsampleGraphics(graphics);
      graphics.setComposite(AlphaComposite.Src);
      graphics.setColor(new Color(0, 0, 0, 0));
      graphics.fillRect(0, 0, silhouette.getWidth(), silhouette.getHeight());
      graphics.drawImage(classified, 183, 178, 644, 655, null);
    } finally {
      graphics.dispose();
      classified.flush();
    }
    clearTransparentRgb(silhouette);
    return silhouette;
  }

  private static int clampByte(int value) {
    return Math.max(0, Math.min(255, value));
  }

  private static BufferedImage createSameScaleComparison(
      BufferedImage reference, Map<String, SvgDocument> masters) {
    BufferedImage referenceMark = createReferenceSilhouette(reference);
    BufferedImage reconstructed = renderSvg(
        masters.get("markLight"), 1000, 1000, Theme.DEFAULT, MaskKind.NONE, PURE_WHITE);
    BufferedImage sheet = createSheet(2240, 1240, PURE_WHITE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready silhouette lock · same-scale comparison",
          60, 62, DEEP_SPACE_BLACK);
      proofText(graphics,
          "Reference and reconstruction share an identical 1000×1000 coordinate frame, white background, and black/green palette.",
          60, 100, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics, "Approved reference mark only", 60, 145,
          27, 600, DEEP_SPACE_BLACK);
      proofText(graphics, "Reconstructed vector only", 1180, 145,
          27, 600, DEEP_SPACE_BLACK);
      graphics.drawImage(referenceMark, 60, 170, null);
      graphics.drawImage(reconstructed, 1180, 170, null);
      graphics.setColor(DEEP_GRAY_BLUE);
      graphics.setStroke(new BasicStroke(2f));
      graphics.drawRect(60, 170, 999, 999);
      graphics.drawRect(1180, 170, 999, 999);
      proofText(graphics,
          "Arc frame 525×605 · W/H 0.868 · bar/dot 1.500 · lower endpoint retracted toward bottom-center",
          60, 1210, 22, 400, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      referenceMark.flush();
      reconstructed.flush();
    }
    return sheet;
  }

  private static BufferedImage createReferenceVectorOverlay(
      BufferedImage reference, Map<String, SvgDocument> masters) {
    BufferedImage referenceMark = createReferenceSilhouette(reference);
    BufferedImage reconstructed = renderSvg(
        masters.get("markLight"), 1000, 1000, Theme.DEFAULT, MaskKind.NONE, null);
    BufferedImage magenta = tintAlpha(referenceMark, rgb("D000FF"));
    BufferedImage cyan = tintAlpha(reconstructed, rgb("00C8FF"));
    BufferedImage sheet = createSheet(1200, 1280, PURE_WHITE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready reference/vector transparent overlay",
          70, 62, DEEP_SPACE_BLACK);
      proofText(graphics,
          "Magenta = approved reference at 50% · Cyan = reconstructed vector at 50% · identical coordinate frame",
          70, 100, 21, 400, DEEP_GRAY_BLUE);
      graphics.setComposite(AlphaComposite.SrcOver.derive(0.5f));
      graphics.drawImage(magenta, 100, 130, null);
      graphics.drawImage(cyan, 100, 130, null);
      graphics.setComposite(AlphaComposite.SrcOver);
      graphics.setColor(DEEP_GRAY_BLUE);
      graphics.setStroke(new BasicStroke(2f));
      graphics.drawRect(100, 130, 999, 999);
      proofText(graphics,
          "Matched regions blend blue; separated magenta/cyan edges expose silhouette or placement differences.",
          100, 1185, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics,
          "Normalization frame: arc outer box x=190, y=185, width=525, height=605.",
          100, 1225, 22, 400, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      referenceMark.flush();
      reconstructed.flush();
      magenta.flush();
      cyan.flush();
    }
    return sheet;
  }

  private static BufferedImage createLandmarkComparison(
      BufferedImage reference, Map<String, SvgDocument> masters) {
    BufferedImage referenceMark = createReferenceSilhouette(reference);
    BufferedImage reconstructed = renderSvg(
        masters.get("markLight"), 1000, 1000, Theme.DEFAULT, MaskKind.NONE, null);
    BufferedImage sheet = createSheet(2200, 1360, PURE_WHITE);
    Graphics2D graphics = sheet.createGraphics();
    try {
      configureProofGraphics(graphics);
      proofTitle(graphics, "Get Ready normalized landmark comparison",
          50, 65, DEEP_SPACE_BLACK);
      proofText(graphics,
          "Every value is normalized to the same arc outer bounding box; endpoint and signal targets are optical measurements.",
          50, 105, 22, 400, DEEP_GRAY_BLUE);
      proofPanel(graphics, 45, 145, 1030, 1150, OFF_WHITE);
      proofPanel(graphics, 1125, 145, 1030, 1150, OFF_WHITE);
      proofText(graphics, "Approved reference", 80, 195, 28, 600, DEEP_SPACE_BLACK);
      proofText(graphics, "Reconstructed vector", 1160, 195, 28, 600, DEEP_SPACE_BLACK);
      graphics.drawImage(referenceMark, 145, 220, 800, 800, null);
      graphics.drawImage(reconstructed, 1225, 220, 800, 800, null);
      drawLandmarkOverlay(graphics, 145, 220, 0.8, true);
      drawLandmarkOverlay(graphics, 1225, 220, 0.8, false);
      proofText(graphics, "U (0.924, 0.181) · L (0.520, 0.934)",
          80, 1080, 23, 600, DEEP_SPACE_BLACK);
      proofText(graphics, "bar (0.957, 0.644) · dot (1.003, 0.914)",
          80, 1120, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics, "W/H 0.868 · stroke/W 0.145 · W/D ≈1.477",
          80, 1160, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics, "U (0.924, 0.190) · L (0.514, 0.934)",
          1160, 1080, 23, 600, DEEP_SPACE_BLACK);
      proofText(graphics, "bar (0.963, 0.646) · dot (1.008, 0.909)",
          1160, 1120, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics, "W/H 0.868 · stroke/W 0.152 · W/D 1.500",
          1160, 1160, 22, 400, DEEP_GRAY_BLUE);
      proofText(graphics,
          "Deltas: lower endpoint (−0.006, 0.000) · bar (+0.006, +0.002) · dot (+0.005, −0.005)",
          80, 1240, 22, 600, TECHNOLOGY_GREEN);
      proofText(graphics,
          "All measured deltas satisfy the requested ≤0.03 position/aspect targets and ≤0.02 stroke-ratio target.",
          80, 1325, 22, 400, DEEP_GRAY_BLUE);
    } finally {
      graphics.dispose();
      referenceMark.flush();
      reconstructed.flush();
    }
    return sheet;
  }

  private static void drawLandmarkOverlay(
      Graphics2D graphics, int originX, int originY, double scale, boolean reference) {
    int frameX = originX + (int) Math.round(ARC_FRAME_X * scale);
    int frameY = originY + (int) Math.round(ARC_FRAME_Y * scale);
    int frameWidth = (int) Math.round(ARC_FRAME_WIDTH * scale);
    int frameHeight = (int) Math.round(ARC_FRAME_HEIGHT * scale);
    graphics.setColor(rgb("6B7280"));
    graphics.setStroke(new BasicStroke(2f));
    graphics.drawRect(frameX, frameY, frameWidth, frameHeight);

    double upperX = reference ? 0.924 : 0.924;
    double upperY = reference ? 0.181 : 0.190;
    double lowerX = reference ? 0.520 : 0.514;
    double lowerY = 0.934;
    double barX = reference ? 0.957 : 0.963;
    double barY = reference ? 0.644 : 0.646;
    double dotX = reference ? 1.003 : 1.008;
    double dotY = reference ? 0.914 : 0.909;
    drawLandmarkPoint(graphics, originX, originY, scale, upperX, upperY,
        rgb("2563EB"), "U");
    drawLandmarkPoint(graphics, originX, originY, scale, lowerX, lowerY,
        rgb("D000FF"), "L");
    drawLandmarkPoint(graphics, originX, originY, scale, barX, barY,
        rgb("15803D"), "B");
    drawLandmarkPoint(graphics, originX, originY, scale, dotX, dotY,
        rgb("EA580C"), "D");
  }

  private static void drawLandmarkPoint(
      Graphics2D graphics,
      int originX,
      int originY,
      double scale,
      double normalizedX,
      double normalizedY,
      Color color,
      String label) {
    int x = originX + (int) Math.round(
        (ARC_FRAME_X + normalizedX * ARC_FRAME_WIDTH) * scale);
    int y = originY + (int) Math.round(
        (ARC_FRAME_Y + normalizedY * ARC_FRAME_HEIGHT) * scale);
    graphics.setColor(color);
    graphics.setStroke(new BasicStroke(3f));
    graphics.drawLine(x - 10, y, x + 10, y);
    graphics.drawLine(x, y - 10, x, y + 10);
    graphics.fill(new Ellipse2D.Double(x - 4, y - 4, 8, 8));
    proofText(graphics, label, x + 12, y - 10, 20, 700, color);
  }

  private static void drawOldThreeStep(
      Graphics2D graphics,
      int x,
      int y,
      int size,
      Color neutral,
      Color green) {
    double scale = size / 1000.0;
    double width = 300.0 * scale;
    double height = 110.0 * scale;
    double arc = 110.0 * scale;
    double[][] positions = {{500, 275}, {350, 445}, {200, 615}};
    Color[] colors = {neutral, green, neutral};
    for (int index = 0; index < positions.length; index++) {
      graphics.setColor(colors[index]);
      graphics.fill(new RoundRectangle2D.Double(
          x + positions[index][0] * scale,
          y + positions[index][1] * scale,
          width,
          height,
          arc,
          arc));
    }
  }

  private static void drawPhoneFrame(
      Graphics2D graphics, BufferedImage screen, int x, int y, int width, int height) {
    graphics.setColor(rgb("070A0F"));
    graphics.fill(new RoundRectangle2D.Double(x, y, width, height, 64, 64));
    graphics.setColor(PANEL_BORDER);
    graphics.setStroke(new BasicStroke(3f));
    graphics.draw(new RoundRectangle2D.Double(x, y, width, height, 64, 64));
    Shape previousClip = graphics.getClip();
    graphics.clip(new RoundRectangle2D.Double(x + 18, y + 18, width - 36, height - 36, 46, 46));
    drawImageCover(graphics, screen, x + 18, y + 18, width - 36, height - 36);
    graphics.setClip(previousClip);
    graphics.setColor(rgb("11161E"));
    graphics.fill(new RoundRectangle2D.Double(
        x + width / 2.0 - 54, y + 28, 108, 17, 17, 17));
  }

  private static void drawSafeAreaOverlay(
      Graphics2D graphics, int x, int y, int size) {
    java.awt.Stroke previous = graphics.getStroke();
    graphics.setColor(new Color(
        TECHNOLOGY_GREEN.getRed(), TECHNOLOGY_GREEN.getGreen(), TECHNOLOGY_GREEN.getBlue(), 210));
    graphics.setStroke(new BasicStroke(2f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_MITER,
        10f, new float[] {10f, 8f}, 0f));
    int inset = (int) Math.round(size * 0.20);
    graphics.drawRect(x + inset, y + inset, size - inset * 2, size - inset * 2);
    graphics.setStroke(previous);
  }

  private static void drawPixelGrid(
      Graphics2D graphics, int x, int y, int pixels, int scale) {
    Color previous = graphics.getColor();
    graphics.setColor(new Color(128, 138, 150, 65));
    graphics.setStroke(new BasicStroke(1f));
    for (int index = 0; index <= pixels; index++) {
      int offset = index * scale;
      graphics.drawLine(x + offset, y, x + offset, y + pixels * scale);
      graphics.drawLine(x, y + offset, x + pixels * scale, y + offset);
    }
    graphics.setColor(previous);
  }

  private static BufferedImage tintAlpha(BufferedImage source, Color color) {
    BufferedImage result = createSrgbImage(source.getWidth(), source.getHeight());
    for (int y = 0; y < source.getHeight(); y++) {
      for (int x = 0; x < source.getWidth(); x++) {
        int alpha = (source.getRGB(x, y) >>> 24) & 0xFF;
        result.setRGB(x, y, (alpha << 24) | (color.getRGB() & 0x00FFFFFF));
      }
    }
    clearTransparentRgb(result);
    return result;
  }

  private static void drawNearestNeighbor(
      Graphics2D graphics, BufferedImage image, int x, int y, int width, int height) {
    Object previous = graphics.getRenderingHint(RenderingHints.KEY_INTERPOLATION);
    graphics.setRenderingHint(
        RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
    graphics.drawImage(image, x, y, width, height, null);
    graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
        previous == null ? RenderingHints.VALUE_INTERPOLATION_BICUBIC : previous);
  }

  private static void drawImageFit(
      Graphics2D graphics,
      BufferedImage image,
      int x,
      int y,
      int width,
      int height,
      Object interpolation) {
    double scale = Math.min((double) width / image.getWidth(), (double) height / image.getHeight());
    int drawWidth = (int) Math.round(image.getWidth() * scale);
    int drawHeight = (int) Math.round(image.getHeight() * scale);
    int drawX = x + (width - drawWidth) / 2;
    int drawY = y + (height - drawHeight) / 2;
    Object previous = graphics.getRenderingHint(RenderingHints.KEY_INTERPOLATION);
    graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, interpolation);
    graphics.drawImage(image, drawX, drawY, drawWidth, drawHeight, null);
    graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
        previous == null ? RenderingHints.VALUE_INTERPOLATION_BICUBIC : previous);
  }

  private static void drawImageCover(
      Graphics2D graphics, BufferedImage image, int x, int y, int width, int height) {
    double scale = Math.max((double) width / image.getWidth(), (double) height / image.getHeight());
    int drawWidth = (int) Math.round(image.getWidth() * scale);
    int drawHeight = (int) Math.round(image.getHeight() * scale);
    int drawX = x + (width - drawWidth) / 2;
    int drawY = y + (height - drawHeight) / 2;
    graphics.drawImage(image, drawX, drawY, drawWidth, drawHeight, null);
  }

  private static void proofPanel(
      Graphics2D graphics, int x, int y, int width, int height, Color color) {
    graphics.setColor(color);
    graphics.fill(new RoundRectangle2D.Double(x, y, width, height, 38, 38));
    graphics.setColor(PANEL_BORDER);
    graphics.setStroke(new BasicStroke(2f));
    graphics.draw(new RoundRectangle2D.Double(x, y, width, height, 38, 38));
  }

  private static void proofTitle(
      Graphics2D graphics, String text, int x, int baseline, Color color) {
    proofText(graphics, text, x, baseline, 46, 600, color);
  }

  private static void proofText(
      Graphics2D graphics,
      String text,
      int x,
      int baseline,
      int size,
      int weight,
      Color color) {
    Font font = chooseInstalledFont(
        "Segoe UI, Arial, sans-serif", text, size, weight, Path.of("proof-sheet-label"));
    graphics.setFont(font);
    graphics.setColor(color);
    graphics.drawString(text, x, baseline);
  }

  private static BufferedImage createSheet(int width, int height, Color background) {
    BufferedImage image = createSrgbImage(width, height);
    Graphics2D graphics = image.createGraphics();
    try {
      graphics.setComposite(AlphaComposite.Src);
      graphics.setColor(background);
      graphics.fillRect(0, 0, width, height);
    } finally {
      graphics.dispose();
    }
    return image;
  }

  private static BufferedImage createSrgbImage(int width, int height) {
    BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    if (!image.getColorModel().getColorSpace().isCS_sRGB()) {
      throw new IllegalStateException("Java2D did not create an sRGB image");
    }
    return image;
  }

  private static void configureVectorGraphics(Graphics2D graphics) {
    graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    graphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
        RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
    graphics.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
    graphics.setRenderingHint(RenderingHints.KEY_STROKE_CONTROL,
        RenderingHints.VALUE_STROKE_PURE);
    graphics.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION,
        RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
    graphics.setRenderingHint(RenderingHints.KEY_COLOR_RENDERING,
        RenderingHints.VALUE_COLOR_RENDER_QUALITY);
  }

  private static void configureDownsampleGraphics(Graphics2D graphics) {
    configureVectorGraphics(graphics);
    graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
        RenderingHints.VALUE_INTERPOLATION_BICUBIC);
  }

  private static void configureProofGraphics(Graphics2D graphics) {
    configureDownsampleGraphics(graphics);
  }

  private static void clearTransparentRgb(BufferedImage image) {
    for (int y = 0; y < image.getHeight(); y++) {
      for (int x = 0; x < image.getWidth(); x++) {
        int argb = image.getRGB(x, y);
        if ((argb >>> 24) == 0 && argb != 0) {
          image.setRGB(x, y, 0);
        }
      }
    }
  }

  private static void writeOutput(
      Path root,
      String relative,
      BufferedImage image,
      String source,
      List<OutputInfo> outputs) throws Exception {
    Path target = checkedOutputPath(root, relative);
    try {
      writePngAtomic(target, image);
      OutputInfo info = inspectPng(root, target, source);
      if (info.width() != image.getWidth() || info.height() != image.getHeight()) {
        throw new IOException("PNG dimensions changed during write: " + target);
      }
      outputs.add(info);
      System.out.println("OK " + relative + " " + info.width() + "x" + info.height());
    } finally {
      image.flush();
    }
  }

  private static Path checkedOutputPath(Path root, String relative) throws IOException {
    String normalizedRelative = relative.replace('\\', '/');
    List<String> allowedPrefixes = List.of(
        "assets/branding/generated/",
        "reports/p11_get_ready_brand_assets/",
        "android/app/src/main/res/mipmap-mdpi/",
        "android/app/src/main/res/mipmap-hdpi/",
        "android/app/src/main/res/mipmap-xhdpi/",
        "android/app/src/main/res/mipmap-xxhdpi/",
        "android/app/src/main/res/mipmap-xxxhdpi/",
        "android/app/src/main/res/drawable-nodpi/");
    boolean allowed = allowedPrefixes.stream().anyMatch(normalizedRelative::startsWith)
        || "docs/screenshots/get_ready_branding.png".equals(normalizedRelative);
    if (!allowed || normalizedRelative.contains("..")) {
      throw new IOException("Generator output is outside its authorized scope: " + relative);
    }
    Path target = root.resolve(normalizedRelative).normalize();
    if (!target.startsWith(root)) {
      throw new IOException("Generator output escaped repository root: " + target);
    }
    return target;
  }

  private static void writePngAtomic(Path target, BufferedImage image) throws Exception {
    Files.createDirectories(target.getParent());
    Path temporary = Files.createTempFile(target.getParent(), ".get-ready-", ".png.tmp");
    try {
      ImageWriter writer = ImageIO.getImageWritersByFormatName("png").next();
      try (ImageOutputStream stream = ImageIO.createImageOutputStream(temporary.toFile())) {
        writer.setOutput(stream);
        ImageWriteParam parameters = writer.getDefaultWriteParam();
        ImageTypeSpecifier type = ImageTypeSpecifier.createFromRenderedImage(image);
        IIOMetadata metadata = writer.getDefaultImageMetadata(type, parameters);
        addSrgbMetadata(metadata);
        writer.write(null, new IIOImage(image, null, metadata), parameters);
      } finally {
        writer.dispose();
      }
      try {
        Files.move(temporary, target,
            StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
      } catch (AtomicMoveNotSupportedException exception) {
        Files.move(temporary, target, StandardCopyOption.REPLACE_EXISTING);
      }
    } finally {
      Files.deleteIfExists(temporary);
    }
  }

  private static void addSrgbMetadata(IIOMetadata metadata) throws Exception {
    String format = "javax_imageio_png_1.0";
    IIOMetadataNode root = (IIOMetadataNode) metadata.getAsTree(format);
    removeMetadataChildren(root, "sRGB");
    removeMetadataChildren(root, "gAMA");

    IIOMetadataNode gamma = new IIOMetadataNode("gAMA");
    gamma.setAttribute("value", "45455");
    root.appendChild(gamma);
    IIOMetadataNode srgb = new IIOMetadataNode("sRGB");
    srgb.setAttribute("renderingIntent", "Perceptual");
    root.appendChild(srgb);
    metadata.setFromTree(format, root);
  }

  private static void removeMetadataChildren(IIOMetadataNode root, String name) {
    for (int index = root.getLength() - 1; index >= 0; index--) {
      Node child = root.item(index);
      if (name.equals(child.getNodeName())) {
        root.removeChild(child);
      }
    }
  }

  private static OutputInfo inspectPng(Path root, Path path, String source) throws Exception {
    BufferedImage image = requireImage(path);
    try {
      if (!image.getColorModel().getColorSpace().isCS_sRGB()) {
        throw new IOException("PNG is not decoded as sRGB: " + path);
      }
      verifyTransparentRgb(image, path);
      byte[] bytes = Files.readAllBytes(path);
      if (!containsAscii(bytes, "sRGB")) {
        throw new IOException("PNG is missing explicit sRGB metadata: " + path);
      }
      return new OutputInfo(
          relativePath(root, path),
          image.getWidth(),
          image.getHeight(),
          image.getColorModel().hasAlpha(),
          bytes.length,
          sha256(bytes),
          source);
    } finally {
      image.flush();
    }
  }

  private static void verifyTransparentRgb(BufferedImage image, Path path) throws IOException {
    for (int y = 0; y < image.getHeight(); y++) {
      for (int x = 0; x < image.getWidth(); x++) {
        int argb = image.getRGB(x, y);
        if ((argb >>> 24) == 0 && (argb & 0x00FFFFFF) != 0) {
          throw new IOException("Transparent RGB fringe at " + x + "," + y + " in " + path);
        }
      }
    }
  }

  private static void assertCorrectedGeometry(Map<String, SvgDocument> masters) {
    for (String key : List.of(
        "mark", "markDark", "markLight", "markMonochrome", "logoVertical")) {
      assertSignalGeometry(
          masters.get(key), 583, 538, 225, 75, 37.5, 719, 735, 75);
      assertArcGeometry(masters.get(key), MASTER_ARC_PATH, 80);
    }
    assertSignalGeometry(
        masters.get("wordmarkHorizontal"),
        218.22, 212.92, 76.5, 25.5, 12.75, 264.46, 279.9, 25.5);
    assertArcGeometry(
        masters.get("wordmarkHorizontal"),
        "M249.5 132 C244.4 111.6 207.68 104.12 180.48 106.84 "
            + "C130.84 110.24 98.2 149.34 98.2 198.98 "
            + "C98.2 246.58 132.2 282.96 176.4 285",
        27.2);
    assertSignalGeometry(
        masters.get("splash"), 803, 718, 225, 75, 37.5, 939, 915, 75);
    assertArcGeometry(
        masters.get("splash"),
        "M895 480 C880 420 772 398 692 406 C546 416 450 531 450 677 "
            + "C450 817 550 924 680 930",
        80);
    assertSignalGeometry(
        masters.get("notification"), 14.24, 13.08, 6, 2, 1, 17.867, 18.333, 2);
    assertArcGeometry(
        masters.get("notification"),
        "M16.693 6.733 C16.293 5.133 13.413 4.547 11.28 4.76 "
            + "C7.387 5.027 4.827 8.093 4.827 11.987 "
            + "C4.827 15.72 7.493 18.573 10.96 18.733",
        2.133);

    double aspectRatio = ARC_FRAME_WIDTH / ARC_FRAME_HEIGHT;
    double strokeRatio = 80.0 / ARC_FRAME_WIDTH;
    assertWithin(aspectRatio, 0.868, 0.03, "arc width/height ratio");
    assertWithin(strokeRatio, 0.145, 0.02, "arc stroke/width ratio");
    assertWithin((675.0 - ARC_FRAME_X) / ARC_FRAME_WIDTH, 0.924, 0.03,
        "upper endpoint x");
    assertWithin((300.0 - ARC_FRAME_Y) / ARC_FRAME_HEIGHT, 0.181, 0.03,
        "upper endpoint y");
    assertWithin((460.0 - ARC_FRAME_X) / ARC_FRAME_WIDTH, 0.520, 0.03,
        "lower endpoint x");
    assertWithin((750.0 - ARC_FRAME_Y) / ARC_FRAME_HEIGHT, 0.934, 0.03,
        "lower endpoint y");
    assertWithin((583.0 + 112.5 - ARC_FRAME_X) / ARC_FRAME_WIDTH, 0.957, 0.03,
        "status-bar center x");
    assertWithin((538.0 + 37.5 - ARC_FRAME_Y) / ARC_FRAME_HEIGHT, 0.644, 0.03,
        "status-bar center y");
    assertWithin((719.0 - ARC_FRAME_X) / ARC_FRAME_WIDTH, 1.003, 0.03,
        "readiness-dot center x");
    assertWithin((735.0 - ARC_FRAME_Y) / ARC_FRAME_HEIGHT, 0.914, 0.03,
        "readiness-dot center y");
    if (583.0 >= ARC_FRAME_X + ARC_FRAME_WIDTH || 719.0 - 75.0 >= ARC_FRAME_X + ARC_FRAME_WIDTH) {
      throw new IllegalArgumentException("Green signal group floats outside the arc opening");
    }
  }

  private static void assertArcGeometry(
      SvgDocument svg, String expectedPath, double expectedStrokeWidth) {
    Element arc = requireElementById(svg, "open-arc", "path");
    String actualPath = arc.getAttribute("d").trim().replaceAll("\\s+", " ");
    String normalizedExpected = expectedPath.trim().replaceAll("\\s+", " ");
    if (!normalizedExpected.equals(actualPath)) {
      throw new IllegalArgumentException(
          "Asymmetric open-arc path mismatch in " + svg.path() + ": " + actualPath);
    }
    assertNearly(number(arc, "stroke-width", Double.NaN, svg.path()),
        expectedStrokeWidth, "open-arc stroke width", svg.path());
    if (!"round".equals(arc.getAttribute("stroke-linecap"))) {
      throw new IllegalArgumentException("Open-arc endpoints must remain round in " + svg.path());
    }
  }

  private static void assertWithin(
      double actual, double expected, double tolerance, String label) {
    if (Math.abs(actual - expected) > tolerance) {
      throw new IllegalArgumentException(
          label + " outside tolerance: expected " + expected + " ± " + tolerance
              + ", found " + actual);
    }
  }

  private static void assertSignalGeometry(
      SvgDocument svg,
      double expectedBarX,
      double expectedBarY,
      double expectedBarWidth,
      double expectedBarHeight,
      double expectedBarRadius,
      double expectedDotX,
      double expectedDotY,
      double expectedDotRadius) {
    Element bar = requireElementById(svg, "status-bar", "rect");
    Element dot = requireElementById(svg, "readiness-dot", "circle");
    Path source = svg.path();

    double barX = number(bar, "x", Double.NaN, source);
    double barY = number(bar, "y", Double.NaN, source);
    double barWidth = number(bar, "width", Double.NaN, source);
    double barHeight = number(bar, "height", Double.NaN, source);
    double barRadius = number(bar, "rx", Double.NaN, source);
    double dotX = number(dot, "cx", Double.NaN, source);
    double dotY = number(dot, "cy", Double.NaN, source);
    double dotRadius = number(dot, "r", Double.NaN, source);

    assertNearly(barX, expectedBarX, "status-bar x", source);
    assertNearly(barY, expectedBarY, "status-bar y", source);
    assertNearly(barWidth, expectedBarWidth, "status-bar width", source);
    assertNearly(barHeight, expectedBarHeight, "status-bar height", source);
    assertNearly(barRadius, expectedBarRadius, "status-bar radius", source);
    assertNearly(dotX, expectedDotX, "readiness-dot cx", source);
    assertNearly(dotY, expectedDotY, "readiness-dot cy", source);
    assertNearly(dotRadius, expectedDotRadius, "readiness-dot radius", source);

    double dotDiameter = dotRadius * 2.0;
    double widthRatio = barWidth / dotDiameter;
    double heightRatio = barHeight / dotDiameter;
    double gapRatio = ((dotY - dotRadius) - (barY + barHeight)) / dotDiameter;
    double centerDelta = dotX - (barX + barWidth / 2.0);

    if (widthRatio < 1.45 || widthRatio > 1.60) {
      throw new IllegalArgumentException(
          "status-bar width/dot ratio outside 1.45..1.60 in " + source + ": " + widthRatio);
    }
    if (heightRatio < 0.48 || heightRatio > 0.55) {
      throw new IllegalArgumentException(
          "status-bar height/dot ratio outside 0.48..0.55 in " + source + ": " + heightRatio);
    }
    if (gapRatio < 0.25 || gapRatio > 0.35) {
      throw new IllegalArgumentException(
          "status-bar/dot edge-gap ratio outside 0.25..0.35 in " + source + ": " + gapRatio);
    }
    double opticalOffsetRatio = centerDelta / dotDiameter;
    if (opticalOffsetRatio < 0.10 || opticalOffsetRatio > 0.20) {
      throw new IllegalArgumentException(
          "readiness-dot optical x offset outside 0.10..0.20 dot diameters in "
              + source + ": " + opticalOffsetRatio);
    }
    assertNearly(barRadius, barHeight / 2.0, "status-bar capsule radius", source);
  }

  private static Element requireElementById(
      SvgDocument svg, String id, String expectedElementName) {
    NodeList elements = svg.document().getDocumentElement().getElementsByTagNameNS("*", "*");
    for (int index = 0; index < elements.getLength(); index++) {
      Element element = (Element) elements.item(index);
      if (id.equals(element.getAttribute("id"))) {
        if (!expectedElementName.equals(elementName(element))) {
          throw new IllegalArgumentException(
              "Expected #" + id + " to be <" + expectedElementName + "> in " + svg.path());
        }
        return element;
      }
    }
    throw new IllegalArgumentException("Missing #" + id + " in " + svg.path());
  }

  private static void assertNearly(
      double actual, double expected, String label, Path source) {
    if (Math.abs(actual - expected) > 0.000001) {
      throw new IllegalArgumentException(
          label + " mismatch in " + source + ": expected " + expected + ", found " + actual);
    }
  }

  private static void assertBrandColors(Path path) throws IOException {
    BufferedImage image = requireImage(path);
    try {
      assertRgb(image, masterPixel(image, 230), masterPixel(image, 497),
          OFF_WHITE, "open arc", path);
      assertRgb(image, masterPixel(image, 695), masterPixel(image, 575),
          TECHNOLOGY_GREEN, "status bar", path);
      assertRgb(image, masterPixel(image, 719), masterPixel(image, 735),
          TECHNOLOGY_GREEN, "readiness dot", path);
      assertRgb(image, masterPixel(image, 500), masterPixel(image, 500),
          DEEP_SPACE_BLACK, "background", path);
    } finally {
      image.flush();
    }
  }

  private static int masterPixel(BufferedImage image, int masterCoordinate) {
    return (int) Math.round(masterCoordinate * (image.getWidth() - 1) / 1000.0);
  }

  private static void assertRgb(
      BufferedImage image, int x, int y, Color expected, String label, Path path) throws IOException {
    int actual = image.getRGB(x, y) & 0x00FFFFFF;
    int expectedRgb = expected.getRGB() & 0x00FFFFFF;
    if (actual != expectedRgb) {
      throw new IOException(label + " color mismatch in " + path + ": expected #"
          + hexRgb(expectedRgb) + ", found #" + hexRgb(actual));
    }
  }

  private static BufferedImage requireImage(Path path) throws IOException {
    BufferedImage image = ImageIO.read(path.toFile());
    if (image == null) {
      throw new IOException("Unable to decode PNG: " + path);
    }
    return image;
  }

  private static void writeManifest(
      Path root, Map<String, SvgDocument> masters, List<OutputInfo> outputs) throws Exception {
    outputs.sort(Comparator.comparing(OutputInfo::path));
    StringBuilder json = new StringBuilder();
    json.append("{\n");
    json.append("  \"schemaVersion\": 1,\n");
    json.append("  \"generator\": \"tools/branding/GenerateGetreadyAssets.java\",\n");
    json.append("  \"command\": \".\\\\tools\\\\branding\\\\generate_getready_assets.ps1\",\n");
    json.append("  \"javaRuntime\": \"").append(jsonEscape(Runtime.version().toString()))
        .append("\",\n");
    json.append("  \"supersampling\": ").append(SUPERSAMPLE).append(",\n");
    json.append("  \"pngColorSpace\": \"sRGB\",\n");
    json.append("  \"fonts\": [");
    int fontIndex = 0;
    for (String font : USED_FONTS) {
      if (fontIndex++ > 0) {
        json.append(", ");
      }
      json.append("\"").append(jsonEscape(font)).append("\"");
    }
    json.append("],\n");

    json.append("  \"sources\": [\n");
    List<SvgDocument> sourceList = new ArrayList<>(masters.values());
    sourceList.sort(Comparator.comparing(svg -> relativePath(root, svg.path())));
    for (int index = 0; index < sourceList.size(); index++) {
      SvgDocument source = sourceList.get(index);
      byte[] bytes = Files.readAllBytes(source.path());
      json.append("    {\"path\": \"")
          .append(jsonEscape(relativePath(root, source.path())))
          .append("\", \"bytes\": ").append(bytes.length)
          .append(", \"sha256\": \"").append(sha256(bytes)).append("\"}");
      json.append(index + 1 == sourceList.size() ? "\n" : ",\n");
    }
    json.append("  ],\n");

    json.append("  \"outputs\": [\n");
    for (int index = 0; index < outputs.size(); index++) {
      OutputInfo output = outputs.get(index);
      json.append("    {\"path\": \"").append(jsonEscape(output.path()))
          .append("\", \"width\": ").append(output.width())
          .append(", \"height\": ").append(output.height())
          .append(", \"alpha\": ").append(output.alpha())
          .append(", \"bytes\": ").append(output.bytes())
          .append(", \"sha256\": \"").append(output.sha256())
          .append("\", \"source\": \"").append(jsonEscape(output.source()))
          .append("\"}");
      json.append(index + 1 == outputs.size() ? "\n" : ",\n");
    }
    json.append("  ]\n");
    json.append("}\n");

    Path manifest = checkedOutputPath(
        root, "assets/branding/generated/get_ready_asset_manifest.json");
    writeTextAtomic(manifest, json.toString());
  }

  private static void writeTextAtomic(Path target, String content) throws IOException {
    Files.createDirectories(target.getParent());
    Path temporary = Files.createTempFile(target.getParent(), ".get-ready-", ".json.tmp");
    try {
      Files.writeString(temporary, content, StandardCharsets.UTF_8);
      try {
        Files.move(temporary, target,
            StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
      } catch (AtomicMoveNotSupportedException exception) {
        Files.move(temporary, target, StandardCopyOption.REPLACE_EXISTING);
      }
    } finally {
      Files.deleteIfExists(temporary);
    }
  }

  private static double number(
      Element element, String attribute, double defaultValue, Path source) {
    if (!element.hasAttribute(attribute)) {
      if (Double.isNaN(defaultValue)) {
        throw new IllegalArgumentException(
            "Missing required '" + attribute + "' on <" + elementName(element) + "> in " + source);
      }
      return defaultValue;
    }
    try {
      double value = Double.parseDouble(element.getAttribute(attribute).trim());
      if (!Double.isFinite(value)) {
        throw new NumberFormatException("non-finite");
      }
      return value;
    } catch (NumberFormatException exception) {
      throw new IllegalArgumentException(
          "Invalid number '" + element.getAttribute(attribute) + "' for " + attribute
              + " in " + source,
          exception);
    }
  }

  private static double[] parseNumberList(
      String value, int expectedCount, String label, Path source) {
    String[] pieces = value.trim().split("[\\s,]+");
    if (pieces.length != expectedCount) {
      throw new IllegalArgumentException(
          label + " requires " + expectedCount + " values in " + source);
    }
    double[] result = new double[expectedCount];
    for (int index = 0; index < expectedCount; index++) {
      try {
        result[index] = Double.parseDouble(pieces[index]);
      } catch (NumberFormatException exception) {
        throw new IllegalArgumentException("Invalid " + label + " in " + source, exception);
      }
    }
    return result;
  }

  private static String requireAttribute(Element element, String name) {
    if (!element.hasAttribute(name) || element.getAttribute(name).isBlank()) {
      throw new IllegalArgumentException(
          "Missing required SVG attribute '" + name + "' on <" + elementName(element) + ">");
    }
    return element.getAttribute(name);
  }

  private static String elementName(Element element) {
    return element.getLocalName() == null ? element.getTagName() : element.getLocalName();
  }

  private static String stripQuotes(String value) {
    if (value.length() >= 2
        && ((value.startsWith("\"") && value.endsWith("\""))
            || (value.startsWith("'") && value.endsWith("'")))) {
      return value.substring(1, value.length() - 1);
    }
    return value;
  }

  private static boolean containsAscii(byte[] bytes, String needle) {
    byte[] target = needle.getBytes(StandardCharsets.US_ASCII);
    outer:
    for (int index = 0; index <= bytes.length - target.length; index++) {
      for (int offset = 0; offset < target.length; offset++) {
        if (bytes[index + offset] != target[offset]) {
          continue outer;
        }
      }
      return true;
    }
    return false;
  }

  private static String sha256(byte[] bytes) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      return toHex(digest.digest(bytes));
    } catch (NoSuchAlgorithmException exception) {
      throw new IllegalStateException("SHA-256 unavailable", exception);
    }
  }

  private static String toHex(byte[] bytes) {
    StringBuilder result = new StringBuilder(bytes.length * 2);
    for (byte value : bytes) {
      result.append(String.format(Locale.ROOT, "%02x", value & 0xFF));
    }
    return result.toString();
  }

  private static String hexRgb(int rgb) {
    return String.format(Locale.ROOT, "%06X", rgb & 0x00FFFFFF);
  }

  private static String jsonEscape(String value) {
    return value
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\r", "\\r")
        .replace("\n", "\\n");
  }

  private static String relativePath(Path root, Path path) {
    return root.relativize(path.toAbsolutePath().normalize()).toString().replace('\\', '/');
  }

  private static Color rgb(String hex) {
    return new Color(Integer.parseInt(hex, 16));
  }
}
