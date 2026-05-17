const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  Header,
  Footer,
  AlignmentType,
  HeadingLevel,
  BorderStyle,
  WidthType,
  ShadingType,
  VerticalAlign,
  PageNumber,
  PageBreak,
  LevelFormat,
  TableOfContents,
  ExternalHyperlink,
} = require("docx");
const fs = require("fs");

const ACCENT = "4F46B8";
const ACCENT_LIGHT = "EEEDFE";
const HEADER_BG = "3B35A0";
const TABLE_HEADER = "4F46B8";
const TABLE_STRIPE = "F5F4FD";
const GRAY_BG = "F3F4F6";
const TEXT_DARK = "1E1B4B";
const TEXT_GRAY = "6B7280";

const border = { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB" };
const borders = { top: border, bottom: border, left: border, right: border };
const noBorder = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
const noBorders = {
  top: noBorder,
  bottom: noBorder,
  left: noBorder,
  right: noBorder,
};

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 180 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 32,
        color: TEXT_DARK,
        font: "Arial",
      }),
    ],
    border: {
      bottom: { style: BorderStyle.SINGLE, size: 6, color: ACCENT, space: 4 },
    },
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 280, after: 140 },
    children: [
      new TextRun({ text, bold: true, size: 26, color: ACCENT, font: "Arial" }),
    ],
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 100 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 22,
        color: TEXT_DARK,
        font: "Arial",
      }),
    ],
  });
}

function para(text, opts = {}) {
  return new Paragraph({
    spacing: { after: 120 },
    children: [
      new TextRun({
        text,
        size: 22,
        font: "Arial",
        color: opts.color || TEXT_DARK,
        bold: opts.bold || false,
        italics: opts.italic || false,
      }),
    ],
    alignment: opts.align || AlignmentType.LEFT,
  });
}

function bullet(text, level = 0) {
  return new Paragraph({
    numbering: { reference: "bullets", level },
    spacing: { after: 80 },
    children: [
      new TextRun({ text, size: 22, font: "Arial", color: TEXT_DARK }),
    ],
  });
}

function numbered(text, level = 0) {
  return new Paragraph({
    numbering: { reference: "numbers", level },
    spacing: { after: 80 },
    children: [
      new TextRun({ text, size: 22, font: "Arial", color: TEXT_DARK }),
    ],
  });
}

function space(before = 100) {
  return new Paragraph({
    spacing: { before, after: 0 },
    children: [new TextRun("")],
  });
}

function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

function makeHeaderRow(cells, colWidths) {
  return new TableRow({
    tableHeader: true,
    children: cells.map(
      (text, i) =>
        new TableCell({
          borders,
          width: { size: colWidths[i], type: WidthType.DXA },
          shading: { fill: TABLE_HEADER, type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          verticalAlign: VerticalAlign.CENTER,
          children: [
            new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [
                new TextRun({
                  text,
                  bold: true,
                  size: 20,
                  color: "FFFFFF",
                  font: "Arial",
                }),
              ],
            }),
          ],
        }),
    ),
  });
}

function makeRow(cells, colWidths, stripe = false) {
  return new TableRow({
    children: cells.map(
      (text, i) =>
        new TableCell({
          borders,
          width: { size: colWidths[i], type: WidthType.DXA },
          shading: {
            fill: stripe ? TABLE_STRIPE : "FFFFFF",
            type: ShadingType.CLEAR,
          },
          margins: { top: 70, bottom: 70, left: 120, right: 120 },
          verticalAlign: VerticalAlign.CENTER,
          children: [
            new Paragraph({
              children: [
                new TextRun({
                  text,
                  size: 20,
                  font: "Arial",
                  color: TEXT_DARK,
                }),
              ],
            }),
          ],
        }),
    ),
  });
}

function infoBox(label, value) {
  return new Table({
    width: { size: 9026, type: WidthType.DXA },
    columnWidths: [2200, 6826],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            borders: noBorders,
            width: { size: 2200, type: WidthType.DXA },
            shading: { fill: ACCENT_LIGHT, type: ShadingType.CLEAR },
            margins: { top: 80, bottom: 80, left: 140, right: 140 },
            children: [
              new Paragraph({
                children: [
                  new TextRun({
                    text: label,
                    bold: true,
                    size: 20,
                    color: ACCENT,
                    font: "Arial",
                  }),
                ],
              }),
            ],
          }),
          new TableCell({
            borders: noBorders,
            width: { size: 6826, type: WidthType.DXA },
            shading: { fill: GRAY_BG, type: ShadingType.CLEAR },
            margins: { top: 80, bottom: 80, left: 140, right: 140 },
            children: [
              new Paragraph({
                children: [
                  new TextRun({
                    text: value,
                    size: 20,
                    font: "Arial",
                    color: TEXT_DARK,
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  });
}

const doc = new Document({
  numbering: {
    config: [
      {
        reference: "bullets",
        levels: [
          {
            level: 0,
            format: LevelFormat.BULLET,
            text: "\u2022",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          },
          {
            level: 1,
            format: LevelFormat.BULLET,
            text: "\u25E6",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 1080, hanging: 360 } } },
          },
        ],
      },
      {
        reference: "numbers",
        levels: [
          {
            level: 0,
            format: LevelFormat.DECIMAL,
            text: "%1.",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          },
        ],
      },
    ],
  },
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      {
        id: "Heading1",
        name: "Heading 1",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 32, bold: true, font: "Arial", color: TEXT_DARK },
        paragraph: { spacing: { before: 360, after: 180 }, outlineLevel: 0 },
      },
      {
        id: "Heading2",
        name: "Heading 2",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 26, bold: true, font: "Arial", color: ACCENT },
        paragraph: { spacing: { before: 280, after: 140 }, outlineLevel: 1 },
      },
      {
        id: "Heading3",
        name: "Heading 3",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 22, bold: true, font: "Arial", color: TEXT_DARK },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 },
      },
    ],
  },
  sections: [
    {
      properties: {
        page: {
          size: { width: 11906, height: 16838 },
          margin: { top: 1440, right: 1260, bottom: 1440, left: 1260 },
        },
      },
      headers: {
        default: new Header({
          children: [
            new Table({
              width: { size: 9386, type: WidthType.DXA },
              columnWidths: [7000, 2386],
              rows: [
                new TableRow({
                  children: [
                    new TableCell({
                      borders: noBorders,
                      width: { size: 7000, type: WidthType.DXA },
                      shading: { fill: "FFFFFF", type: ShadingType.CLEAR },
                      margins: { top: 60, bottom: 60, left: 0, right: 0 },
                      children: [
                        new Paragraph({
                          children: [
                            new TextRun({
                              text: "Tài liệu Dự án Flutter  |  App Theo dõi Anime / Phim",
                              size: 18,
                              color: TEXT_GRAY,
                              font: "Arial",
                            }),
                          ],
                        }),
                      ],
                    }),
                    new TableCell({
                      borders: noBorders,
                      width: { size: 2386, type: WidthType.DXA },
                      shading: { fill: "FFFFFF", type: ShadingType.CLEAR },
                      margins: { top: 60, bottom: 60, left: 0, right: 0 },
                      children: [
                        new Paragraph({
                          alignment: AlignmentType.RIGHT,
                          children: [
                            new TextRun({
                              text: "Trang ",
                              size: 18,
                              color: TEXT_GRAY,
                              font: "Arial",
                            }),
                            new TextRun({
                              children: [PageNumber.CURRENT],
                              size: 18,
                              color: TEXT_GRAY,
                              font: "Arial",
                            }),
                            new TextRun({
                              text: " / ",
                              size: 18,
                              color: TEXT_GRAY,
                              font: "Arial",
                            }),
                            new TextRun({
                              children: [PageNumber.TOTAL_PAGES],
                              size: 18,
                              color: TEXT_GRAY,
                              font: "Arial",
                            }),
                          ],
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
            new Paragraph({
              border: {
                bottom: { style: BorderStyle.SINGLE, size: 4, color: ACCENT },
              },
              children: [],
            }),
          ],
        }),
      },
      children: [
        // ─── COVER ───────────────────────────────────────────────
        new Paragraph({
          spacing: { before: 1440, after: 0 },
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: "TÀI LIỆU DỰ ÁN",
              size: 20,
              color: TEXT_GRAY,
              font: "Arial",
              allCaps: true,
              characterSpacing: 120,
            }),
          ],
        }),
        new Paragraph({
          spacing: { before: 120, after: 0 },
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: "Flutter Mobile Application",
              size: 28,
              bold: true,
              color: ACCENT,
              font: "Arial",
            }),
          ],
        }),
        space(600),
        new Paragraph({
          spacing: { before: 0, after: 0 },
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: "AnimeTracker",
              size: 72,
              bold: true,
              color: TEXT_DARK,
              font: "Arial",
            }),
          ],
        }),
        new Paragraph({
          spacing: { before: 120, after: 0 },
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: "App Theo dõi Anime & Phim Cá nhân",
              size: 30,
              color: ACCENT,
              font: "Arial",
              italics: true,
            }),
          ],
        }),
        space(480),
        new Table({
          width: { size: 5000, type: WidthType.DXA },
          columnWidths: [2200, 2800],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders,
                  width: { size: 2200, type: WidthType.DXA },
                  shading: { fill: ACCENT_LIGHT, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Danh mục",
                          bold: true,
                          size: 20,
                          color: ACCENT,
                          font: "Arial",
                        }),
                      ],
                    }),
                  ],
                }),
                new TableCell({
                  borders,
                  width: { size: 2800, type: WidthType.DXA },
                  shading: { fill: GRAY_BG, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Giải trí",
                          size: 20,
                          font: "Arial",
                          color: TEXT_DARK,
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders,
                  width: { size: 2200, type: WidthType.DXA },
                  shading: { fill: ACCENT_LIGHT, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Độ khó",
                          bold: true,
                          size: 20,
                          color: ACCENT,
                          font: "Arial",
                        }),
                      ],
                    }),
                  ],
                }),
                new TableCell({
                  borders,
                  width: { size: 2800, type: WidthType.DXA },
                  shading: { fill: GRAY_BG, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Trung bình",
                          size: 20,
                          font: "Arial",
                          color: TEXT_DARK,
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders,
                  width: { size: 2200, type: WidthType.DXA },
                  shading: { fill: ACCENT_LIGHT, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Lưu trữ",
                          bold: true,
                          size: 20,
                          color: ACCENT,
                          font: "Arial",
                        }),
                      ],
                    }),
                  ],
                }),
                new TableCell({
                  borders,
                  width: { size: 2800, type: WidthType.DXA },
                  shading: { fill: GRAY_BG, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "REST API + sqflite",
                          size: 20,
                          font: "Arial",
                          color: TEXT_DARK,
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
            new TableRow({
              children: [
                new TableCell({
                  borders,
                  width: { size: 2200, type: WidthType.DXA },
                  shading: { fill: ACCENT_LIGHT, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "Phiên bản",
                          bold: true,
                          size: 20,
                          color: ACCENT,
                          font: "Arial",
                        }),
                      ],
                    }),
                  ],
                }),
                new TableCell({
                  borders,
                  width: { size: 2800, type: WidthType.DXA },
                  shading: { fill: GRAY_BG, type: ShadingType.CLEAR },
                  margins: { top: 80, bottom: 80, left: 120, right: 120 },
                  children: [
                    new Paragraph({
                      alignment: AlignmentType.CENTER,
                      children: [
                        new TextRun({
                          text: "1.0.0  |  2025",
                          size: 20,
                          font: "Arial",
                          color: TEXT_DARK,
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
          ],
        }),
        pageBreak(),

        // ─── TOC ─────────────────────────────────────────────────
        h1("Mục lục"),
        new TableOfContents("Mục lục", {
          hyperlink: true,
          headingStyleRange: "1-3",
          stylesWithLevels: [
            { styleName: "Heading1", level: 1 },
            { styleName: "Heading2", level: 2 },
            { styleName: "Heading3", level: 3 },
          ],
        }),
        pageBreak(),

        // ─── 1. TONG QUAN ─────────────────────────────────────────
        h1("1. Tổng quan dự án"),
        h2("1.1. Mô tả"),
        para(
          "AnimeTracker là ứng dụng di động được xây dựng bằng Flutter, cho phép người dùng quản lý danh sách anime và phim đang theo dõi một cách tiện lợi. Ứng dụng kết hợp Jikan API (cơ sở dữ liệu MyAnimeList) với lưu trữ local để mang lại trải nghiệm mượt mà, có thể sử dụng cả khi ngoài mạng.",
        ),
        para(
          "Dự án được thiết kế nhằm đáp ứng đầy đủ các yêu cầu kỹ thuật của assignment Flutter, bao gồm UI/UX có responsive design, form validation, navigation nhiều màn hình, state management, xử lý dữ liệu bất đồng bộ (async), REST API và cơ sở dữ liệu local.",
        ),
        space(100),

        h2("1.2. Mục tiêu chức năng"),
        bullet(
          "Xem danh sách anime đang phát hành, top xếp hạng, theo thể loại",
        ),
        bullet("Tìm kiếm anime theo tên với kết quả theo thời gian thực"),
        bullet(
          "Xem thông tin chi tiết: poster, synopsis, số tập, studio, điểm MAL",
        ),
        bullet(
          "Thêm anime vào danh sách cá nhân với các trạng thái: Đang xem, Đã xem, Dự định xem, Tạm dừng, Bỏ dở",
        ),
        bullet("Ghi chép tiến độ xem tập, đánh giá cá nhân (1-10 sao)"),
        bullet(
          "Xem thống kê cá nhân: biểu đồ theo thể loại, tổng số tập, hoạt động theo tháng",
        ),
        space(100),

        h2("1.3. Thông tin dự án"),
        infoBox("Tên dự án", "AnimeTracker - Theo dõi Anime & Phim"),
        space(60),
        infoBox("Nền tảng", "Flutter (Dart) - Android & iOS"),
        space(60),
        infoBox(
          "API chính",
          "Jikan API v4 (api.jikan.moe) - Miễn phí, không cần API key",
        ),
        space(60),
        infoBox("Cơ sở dữ liệu", "sqflite (local) + cached_network_image"),
        space(60),
        infoBox("State Management", "Riverpod hoặc Provider"),
        space(60),
        infoBox("Số màn hình", "6 màn hình chính + các dialog"),
        pageBreak(),

        // ─── 2. CHUC NANG ─────────────────────────────────────────
        h1("2. Các màn hình và chức năng"),
        h2("2.1. Màn hình Trang chủ (Home Screen)"),
        para("Màn hình chính hiển thị tổng quan nội dung anime:"),
        bullet("Section 'Đang chiếu mùa này': lấy từ Jikan API /seasons/now"),
        bullet("Section 'Top Anime': lấy từ /top/anime, hiển thị top 10"),
        bullet(
          "Section 'Xem tiếp': lấy từ local DB, các anime có trạng thái 'Đang xem'",
        ),
        bullet("Navigation bar dưới cùng: Home, Tìm kiếm, Danh sách, Thống kê"),
        bullet("Nút chuyển Light/Dark mode ở thanh AppBar"),
        space(100),

        h2("2.2. Màn hình Tìm kiếm (Search Screen)"),
        bullet("TextField tìm kiếm với debounce 500ms, tránh gọi API liên tục"),
        bullet(
          "Kết quả hiển thị theo Grid 2 cột, mỗi item là anime card với poster và tên",
        ),
        bullet(
          "Bộ lọc theo thể loại (Action, Romance, Sci-Fi...) và năm phát hành",
        ),
        bullet("Xử lý trạng thái: loading skeleton, empty state, error state"),
        bullet("Form validation: cảnh báo khi từ khóa quá ngắn (dưới 2 ký tự)"),
        space(100),

        h2("2.3. Màn hình Chi tiết (Detail Screen)"),
        bullet(
          "SliverAppBar: poster mở rộng khi ở đầu, thu gọn khi cuộn xuống",
        ),
        bullet("Hero animation: poster bay từ màn hình danh sách vào chi tiết"),
        bullet(
          "Thông tin đầy đủ: synopsis, thể loại, số tập, studio, điểm MAL, năm phát hành",
        ),
        bullet("Nút Thêm vào danh sách: mở BottomSheet chọn trạng thái"),
        bullet(
          "Nếu đã có trong danh sách: hiển thị trạng thái hiện tại, nút Cập nhật tiến độ",
        ),
        bullet("Các tập đã xem: progress bar hiển thị X / tổng số tập"),
        space(100),

        h2("2.4. Màn hình Danh sách (My List Screen)"),
        bullet("TabBar 5 tab: Tất cả | Đang xem | Đã xem | Dự định | Bỏ dở"),
        bullet("Mỗi anime card hiển thị: poster, tên, trạng thái, tiến độ tập"),
        bullet("Vuốt trái để xóa, nhấn giữ để đổi trạng thái"),
        bullet("Sắp xếp theo: Tên A-Z, Ngày thêm, Điểm cá nhân"),
        bullet("Tìm kiếm nhanh trong danh sách local"),
        space(100),

        h2("2.5. Màn hình Thống kê (Stats Screen)"),
        bullet("Tổng số: anime đã xem, tổng số tập, điểm trung bình cá nhân"),
        bullet("Biểu đồ tròn (Pie Chart): phân bổ theo thể loại"),
        bullet("Biểu đồ cột (Bar Chart): số anime thêm vào theo từng tháng"),
        bullet("Danh sách: Top 5 anime điểm cao nhất của bản thân"),
        space(100),

        h2("2.6. Màn hình Hồ sơ (Profile Screen)"),
        bullet("Tên hiển thị, avatar (có thể chỉnh sửa)"),
        bullet("Thống kê ngắn gọn: tổng anime, tập đã xem"),
        bullet("Cài đặt: Light/Dark mode, ngôn ngữ, thông báo"),
        bullet("Nút Xuất dữ liệu (export JSON) và Xóa toàn bộ dữ liệu"),
        pageBreak(),

        // ─── 3. KIEN TRUC KY THUAT ────────────────────────────────
        h1("3. Kiến trúc kỹ thuật"),
        h2("3.1. Sơ đồ kiến trúc tổng thể"),
        para(
          "Dự án sử dụng kiến trúc Clean Architecture kết hợp với Pattern Repository để tách biệt logic nghiệp vụ khỏi giao diện:",
        ),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2200, 6826],
          rows: [
            makeHeaderRow(["Tầng", "Thành phần"], [2200, 6826]),
            makeRow(
              ["Presentation", "Screens, Widgets, Providers (Riverpod)"],
              [2200, 6826],
              false,
            ),
            makeRow(
              ["Domain", "Use Cases, Entities, Repository Interface"],
              [2200, 6826],
              true,
            ),
            makeRow(
              ["Data", "Repository Impl, API Service, Local DB Service"],
              [2200, 6826],
              false,
            ),
            makeRow(
              [
                "Infrastructure",
                "Jikan API (HTTP), sqflite (local), SharedPreferences",
              ],
              [2200, 6826],
              true,
            ),
          ],
        }),
        space(200),

        h2("3.2. Cấu trúc thư mục"),
        para("Cấu trúc dự án theo Clean Architecture:"),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [3200, 5826],
          rows: [
            makeHeaderRow(["Đường dẫn", "Mô tả"], [3200, 5826]),
            makeRow(
              ["lib/main.dart", "Điểm khởi đầu, cấu hình Riverpod, Router"],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/core/", "Constants, Themes, Router, Dependency Injection"],
              [3200, 5826],
              true,
            ),
            makeRow(
              [
                "lib/features/home/",
                "Màn hình trang chủ: screens, providers, widgets",
              ],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/features/search/", "Màn hình tìm kiếm và bộ lọc"],
              [3200, 5826],
              true,
            ),
            makeRow(
              ["lib/features/detail/", "Màn hình chi tiết anime"],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/features/mylist/", "Màn hình danh sách cá nhân"],
              [3200, 5826],
              true,
            ),
            makeRow(
              ["lib/features/stats/", "Màn hình thống kê biểu đồ"],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/data/api/", "JikanApiService: các hàm gọi HTTP"],
              [3200, 5826],
              true,
            ),
            makeRow(
              ["lib/data/local/", "DatabaseHelper: sqflite CRUD"],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/data/models/", "AnimeModel, WatchlistModel (JSON mapping)"],
              [3200, 5826],
              true,
            ),
            makeRow(
              ["lib/domain/entities/", "Anime, WatchItem (pure Dart classes)"],
              [3200, 5826],
              false,
            ),
            makeRow(
              ["lib/domain/repositories/", "Interface cho API và Local DB"],
              [3200, 5826],
              true,
            ),
          ],
        }),
        pageBreak(),

        // ─── 4. DATABASE ──────────────────────────────────────────
        h1("4. Thiết kế cơ sở dữ liệu"),
        h2("4.1. Bảng watchlist"),
        para("Bảng lưu trữ danh sách anime đang theo dõi của người dùng:"),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2000, 1800, 2000, 3226],
          rows: [
            makeHeaderRow(
              ["Trường", "Kiểu dữ liệu", "Ràng buộc", "Mô tả"],
              [2000, 1800, 2000, 3226],
            ),
            makeRow(
              ["id", "INTEGER", "PRIMARY KEY", "Khóa chính tự động tăng"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              [
                "mal_id",
                "INTEGER",
                "UNIQUE, NOT NULL",
                "ID anime trên MyAnimeList",
              ],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              ["title", "TEXT", "NOT NULL", "Tên anime (tiếng Anh)"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["title_japanese", "TEXT", "NULL", "Tên anime (tiếng Nhật)"],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              ["poster_url", "TEXT", "NOT NULL", "URL ảnh poster"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              [
                "status",
                "TEXT",
                "NOT NULL",
                "watching/completed/plan/hold/dropped",
              ],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              [
                "episodes_total",
                "INTEGER",
                "NULL",
                "Tổng số tập (null = chưa rõ)",
              ],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["episodes_watched", "INTEGER", "DEFAULT 0", "Số tập đã xem"],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              ["score_user", "REAL", "NULL, 1-10", "Điểm đánh giá cá nhân"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["genres", "TEXT", "NULL", "JSON array các thể loại"],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              ["added_at", "TEXT", "NOT NULL", "ISO8601 ngày thêm vào"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["updated_at", "TEXT", "NOT NULL", "ISO8601 lần cập nhật cuối"],
              [2000, 1800, 2000, 3226],
              true,
            ),
          ],
        }),
        space(200),

        h2("4.2. Bảng notes"),
        para("Bảng lưu ghi chú cá nhân cho từng anime:"),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2000, 1800, 2000, 3226],
          rows: [
            makeHeaderRow(
              ["Trường", "Kiểu dữ liệu", "Ràng buộc", "Mô tả"],
              [2000, 1800, 2000, 3226],
            ),
            makeRow(
              ["id", "INTEGER", "PRIMARY KEY", "Khóa chính tự động tăng"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              [
                "mal_id",
                "INTEGER",
                "FOREIGN KEY",
                "Tham chiếu đến watchlist.mal_id",
              ],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              ["content", "TEXT", "NOT NULL", "Nội dung ghi chú"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["created_at", "TEXT", "NOT NULL", "ISO8601 ngày tạo"],
              [2000, 1800, 2000, 3226],
              true,
            ),
          ],
        }),
        space(200),

        h2("4.3. Bảng watch_history"),
        para("Bảng ghi lại lịch sử hoạt động của người dùng:"),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2000, 1800, 2000, 3226],
          rows: [
            makeHeaderRow(
              ["Trường", "Kiểu dữ liệu", "Ràng buộc", "Mô tả"],
              [2000, 1800, 2000, 3226],
            ),
            makeRow(
              ["id", "INTEGER", "PRIMARY KEY", "Khóa chính tự động tăng"],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              [
                "mal_id",
                "INTEGER",
                "FOREIGN KEY",
                "Tham chiếu đến watchlist.mal_id",
              ],
              [2000, 1800, 2000, 3226],
              true,
            ),
            makeRow(
              [
                "action",
                "TEXT",
                "NOT NULL",
                "added/status_changed/episode_updated",
              ],
              [2000, 1800, 2000, 3226],
              false,
            ),
            makeRow(
              ["action_at", "TEXT", "NOT NULL", "ISO8601 thời điểm thực hiện"],
              [2000, 1800, 2000, 3226],
              true,
            ),
          ],
        }),
        pageBreak(),

        // ─── 5. API ───────────────────────────────────────────────
        h1("5. Jikan API - Tài liệu sử dụng"),
        h2("5.1. Thông tin chung"),
        infoBox("Base URL", "https://api.jikan.moe/v4"),
        space(60),
        infoBox("Xác thực", "Không cần API key - truy cập công khai"),
        space(60),
        infoBox(
          "Rate Limit",
          "3 request/giây - cần xử lý debounce khi tìm kiếm",
        ),
        space(60),
        infoBox("Format trả về", "JSON - trường data chứa kết quả chính"),
        space(200),

        h2("5.2. Các endpoint sử dụng"),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [3400, 2400, 3226],
          rows: [
            makeHeaderRow(
              ["Endpoint", "Method", "Chức năng"],
              [3400, 2400, 3226],
            ),
            makeRow(
              [
                "/anime?q={query}&page={n}",
                "GET",
                "Tìm kiếm anime theo tên, phân trang",
              ],
              [3400, 2400, 3226],
              false,
            ),
            makeRow(
              ["/anime/{id}", "GET", "Lấy chi tiết một anime theo mal_id"],
              [3400, 2400, 3226],
              true,
            ),
            makeRow(
              ["/seasons/now", "GET", "Anime đang phát hành mùa này"],
              [3400, 2400, 3226],
              false,
            ),
            makeRow(
              ["/top/anime", "GET", "Top anime xếp theo điểm số"],
              [3400, 2400, 3226],
              true,
            ),
            makeRow(
              ["/anime?genres={id}", "GET", "Lọc anime theo ID thể loại"],
              [3400, 2400, 3226],
              false,
            ),
            makeRow(
              ["/genres/anime", "GET", "Lấy danh sách tất cả thể loại"],
              [3400, 2400, 3226],
              true,
            ),
          ],
        }),
        space(200),

        h2("5.3. Xử lý lỗi API"),
        bullet("200 OK: thành công, đọc trường data"),
        bullet(
          "400 Bad Request: tham số không hợp lệ, hiện thông báo cho người dùng",
        ),
        bullet("404 Not Found: anime không tồn tại"),
        bullet(
          "429 Too Many Requests: vượt rate limit - xử lý bằng Retry-After header",
        ),
        bullet("500+ Server Error: hiện empty state, cho phép pull-to-refresh"),
        pageBreak(),

        // ─── 6. PACKAGES ─────────────────────────────────────────
        h1("6. Flutter Packages và thư viện"),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2400, 1800, 4826],
          rows: [
            makeHeaderRow(
              ["Package", "Phiên bản", "Mục đích sử dụng"],
              [2400, 1800, 4826],
            ),
            makeRow(
              ["http", "^1.2.0", "Gọi REST API đến Jikan - HTTP GET requests"],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              [
                "flutter_riverpod",
                "^2.5.0",
                "State management - quản lý trạng thái toàn cục",
              ],
              [2400, 1800, 4826],
              true,
            ),
            makeRow(
              [
                "sqflite",
                "^2.3.3",
                "Cơ sở dữ liệu SQL local - lưu watchlist, notes",
              ],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              ["path_provider", "^2.1.3", "Lấy đường dẫn thư mục lưu sqflite"],
              [2400, 1800, 4826],
              true,
            ),
            makeRow(
              [
                "cached_network_image",
                "^3.3.1",
                "Cache poster anime, placeholder skeleton",
              ],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              [
                "fl_chart",
                "^0.68.0",
                "Biểu đồ tròn và biểu đồ cột cho màn hình Stats",
              ],
              [2400, 1800, 4826],
              true,
            ),
            makeRow(
              [
                "shimmer",
                "^3.0.0",
                "Hiệu ứng loading skeleton khi chờ API trả về",
              ],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              [
                "flutter_rating_bar",
                "^4.0.1",
                "Widget đánh giá sao (1-10) cá nhân",
              ],
              [2400, 1800, 4826],
              true,
            ),
            makeRow(
              [
                "go_router",
                "^13.2.0",
                "Quản lý navigation, deep link, named routes",
              ],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              ["intl", "^0.19.0", "Định dạng ngày giờ, số theo locale"],
              [2400, 1800, 4826],
              true,
            ),
            makeRow(
              [
                "shared_preferences",
                "^2.2.3",
                "Lưu cài đặt người dùng: dark mode, ngôn ngữ",
              ],
              [2400, 1800, 4826],
              false,
            ),
            makeRow(
              [
                "connectivity_plus",
                "^6.0.3",
                "Kiểm tra kết nối mạng, hiện cảnh báo offline",
              ],
              [2400, 1800, 4826],
              true,
            ),
          ],
        }),
        pageBreak(),

        // ─── 7. TINH NANG NANG CAO ───────────────────────────────
        h1("7. Tính năng nâng cao"),
        h2("7.1. Hero Animation"),
        para(
          "Hero animation được áp dụng khi người dùng nhấn vào poster anime:",
        ),
        bullet(
          "Wrap widget Image.network bằng Hero(tag: 'anime-poster-${mal_id}')",
        ),
        bullet("Màn hình Detail sử dụng cùng tag Hero để kích hoạt animation"),
        bullet("Flutter tự động xử lý animation bay poster giữa 2 màn hình"),
        bullet(
          "Tạo cảm giác mượt mà và chuyên nghiệp, tương tự Netflix/Crunchyroll",
        ),
        space(100),

        h2("7.2. SliverAppBar trên màn hình Detail"),
        para("SliverAppBar tạo hiệu ứng cuộn poster chuyên nghiệp:"),
        bullet(
          "SliverAppBar với expandedHeight: 300 và flexibleSpace: FlexibleSpaceBar",
        ),
        bullet("Poster hiển thị đầy đủ khi ở đầu màn hình"),
        bullet(
          "AppBar thu gọn với tên anime hiện ra khi người dùng cuộn xuống",
        ),
        bullet("Nút quay lại và nút thêm vào danh sách luôn hiển thị"),
        space(100),

        h2("7.3. Offline Support"),
        para("Ứng dụng hoạt động được khi không có mạng:"),
        bullet("cached_network_image lưu poster vào cache local"),
        bullet("Danh sách cá nhân (watchlist) lấy từ sqflite - không cần mạng"),
        bullet("Hiện cảnh báo 'Đang offline' qua connectivity_plus"),
        bullet("Pull-to-refresh để cập nhật khi có kết nối trở lại"),
        space(100),

        h2("7.4. Thống kê với fl_chart"),
        para("Màn hình thống kê hiển thị dữ liệu trực quan:"),
        bullet(
          "PieChart: phân bổ thể loại anime trong watchlist (chia theo genres)",
        ),
        bullet("BarChart: số lượng anime thêm vào theo từng tháng trong năm"),
        bullet(
          "Summary cards: tổng số anime, tổng số tập đã xem, điểm trung bình",
        ),
        bullet("Biểu đồ có animation khi lần đầu load và khi dữ liệu thay đổi"),
        pageBreak(),

        // ─── 8. UI/UX ─────────────────────────────────────────────
        h1("8. Thiết kế UI/UX"),
        h2("8.1. Design System"),
        para("Ứng dụng sử dụng Material Design 3 (Material You) làm nền tảng:"),
        space(80),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2400, 3400, 3226],
          rows: [
            makeHeaderRow(
              ["Thành phần", "Giá trị", "Chú thích"],
              [2400, 3400, 3226],
            ),
            makeRow(
              [
                "Primary Color",
                "#4F46B8 (Indigo)",
                "Màu chính - button, icon, accent",
              ],
              [2400, 3400, 3226],
              false,
            ),
            makeRow(
              [
                "Secondary Color",
                "#7C3AED (Purple)",
                "Màu phụ - badge, chip, tags",
              ],
              [2400, 3400, 3226],
              true,
            ),
            makeRow(
              [
                "Font chính",
                "Inter / Roboto",
                "Font hệ thống, hiển thị rõ ràng",
              ],
              [2400, 3400, 3226],
              false,
            ),
            makeRow(
              [
                "Border Radius",
                "12px (card), 8px (button)",
                "Góc bo nhẹ, hiện đại",
              ],
              [2400, 3400, 3226],
              true,
            ),
            makeRow(
              ["Spacing", "8px grid system", "Khoảng cách theo bội số của 8"],
              [2400, 3400, 3226],
              false,
            ),
            makeRow(
              [
                "Elevation",
                "0dp (flat design)",
                "Không box-shadow, dùng border",
              ],
              [2400, 3400, 3226],
              true,
            ),
          ],
        }),
        space(200),

        h2("8.2. Light / Dark Mode"),
        bullet("ThemeData.light() và ThemeData.dark() định nghĩa đầy đủ"),
        bullet("SharedPreferences lưu lựa chọn của người dùng"),
        bullet("Riverpod Provider quản lý trạng thái theme toàn ứng dụng"),
        bullet("Chuyển đổi tức thời không cần restart app"),
        bullet(
          "System theme tự động theo cài đặt điện thoại (MediaQuery.platformBrightness)",
        ),
        space(100),

        h2("8.3. Responsive Design"),
        bullet("LayoutBuilder kiểm tra chiều rộng màn hình"),
        bullet("Grid 2 cột trên điện thoại, 3 cột trên tablet (>600px)"),
        bullet("Text scale theo font size cài đặt của hệ điều hành"),
        bullet("Safe area xử lý notch và gesture bar"),
        pageBreak(),

        // ─── 9. XU LY LOI ────────────────────────────────────────
        h1("9. Xử lý lỗi và trạng thái"),
        h2("9.1. Các trạng thái hiển thị"),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [2200, 6826],
          rows: [
            makeHeaderRow(["Trạng thái", "Xử lý"], [2200, 6826]),
            makeRow(
              ["Loading", "Shimmer skeleton animation thay thế cho nội dung"],
              [2200, 6826],
              false,
            ),
            makeRow(
              ["Success", "Hiển thị dữ liệu bình thường"],
              [2200, 6826],
              true,
            ),
            makeRow(
              ["Empty", "Hình minh họa + thông báo + nút hành động"],
              [2200, 6826],
              false,
            ),
            makeRow(
              [
                "Error (mạng)",
                "Thông báo lỗi + nút 'Thử lại' + dữ liệu cache nếu có",
              ],
              [2200, 6826],
              true,
            ),
            makeRow(
              ["Error (server)", "Thông báo 'Hệ thống đang bảo trì', log lỗi"],
              [2200, 6826],
              false,
            ),
            makeRow(
              [
                "Offline",
                "Banner cảnh báo trên đầu, vẫn dùng được với dữ liệu local",
              ],
              [2200, 6826],
              true,
            ),
          ],
        }),
        space(200),

        h2("9.2. Form Validation"),
        bullet("Tìm kiếm: cảnh báo nếu nhập dưới 2 ký tự"),
        bullet("Đánh giá sao: bắt buộc chọn 1-10 trước khi lưu"),
        bullet("Ghi chú: giới hạn 500 ký tự, hiện đếm ký tự còn lại"),
        bullet(
          "Nhập số tập: chỉ nhập số nguyên dương, không vượt quá tổng số tập",
        ),
        pageBreak(),

        // ─── 10. LO TRINH PHAT TRIEN ──────────────────────────────
        h1("10. Lộ trình phát triển"),
        h2("10.1. Giai đoạn 1 - Nền tảng (Tuần 1-2)"),
        numbered("Cấu hình dự án: pubspec.yaml, cấu trúc thư mục, theme"),
        numbered("Triển khai Jikan API Service: các hàm gọi HTTP có xử lý lỗi"),
        numbered("Tạo models: AnimeModel, WatchlistModel với JSON parsing"),
        numbered("Cài đặt sqflite: tạo bảng, CRUD cơ bản"),
        numbered("Màn hình Home: hiển thị danh sách từ API"),
        space(100),

        h2("10.2. Giai đoạn 2 - Tính năng chính (Tuần 3-4)"),
        numbered("Màn hình Search: tìm kiếm với debounce, bộ lọc"),
        numbered(
          "Màn hình Detail: SliverAppBar, thông tin đầy đủ, Hero animation",
        ),
        numbered("Màn hình My List: TabBar, CRUD watchlist"),
        numbered("State management: Riverpod providers cho toàn bộ app"),
        numbered("Navigation: go_router cấu hình route đầy đủ"),
        space(100),

        h2("10.3. Giai đoạn 3 - Nâng cao và hoàn thiện (Tuần 5)"),
        numbered("Màn hình Stats: fl_chart biểu đồ tròn và cột"),
        numbered("Dark/Light mode và lưu cài đặt"),
        numbered("Offline support: cached_network_image, kiểm tra mạng"),
        numbered("UI polish: animation, loading states, empty states"),
        numbered("Test trên thiết bị thật, sửa lỗi, tối ưu hiệu suất"),
        pageBreak(),

        // ─── 11. CHAY DU AN ───────────────────────────────────────
        h1("11. Hướng dẫn chạy dự án"),
        h2("11.1. Yêu cầu hệ thống"),
        bullet("Flutter SDK >= 3.19.0 (flutter --version để kiểm tra)"),
        bullet("Dart SDK >= 3.3.0 (kèm theo Flutter)"),
        bullet("Android Studio hoặc VS Code với Flutter extension"),
        bullet(
          "Android Emulator hoặc thiết bị thật (Android >= 5.0, iOS >= 12.0)",
        ),
        space(100),

        h2("11.2. Cài đặt và chạy"),
        numbered(
          "Clone dự án: git clone https://github.com/username/anime-tracker.git",
        ),
        numbered("Vào thư mục: cd anime-tracker"),
        numbered("Cài đặt packages: flutter pub get"),
        numbered("Chạy app: flutter run"),
        numbered("Build release Android: flutter build apk --release"),
        space(100),

        h2("11.3. Cấu hình môi trường"),
        para("Tạo file lib/core/constants/api_constants.dart:"),
        space(60),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [9026],
          rows: [
            new TableRow({
              children: [
                new TableCell({
                  borders,
                  width: { size: 9026, type: WidthType.DXA },
                  shading: { fill: "1E1B4B", type: ShadingType.CLEAR },
                  margins: { top: 120, bottom: 120, left: 180, right: 180 },
                  children: [
                    new Paragraph({
                      children: [
                        new TextRun({
                          text: "class ApiConstants {",
                          size: 20,
                          font: "Courier New",
                          color: "E2E8F0",
                        }),
                      ],
                    }),
                    new Paragraph({
                      children: [
                        new TextRun({
                          text: "  static const String baseUrl = 'https://api.jikan.moe/v4';",
                          size: 20,
                          font: "Courier New",
                          color: "86EFAC",
                        }),
                      ],
                    }),
                    new Paragraph({
                      children: [
                        new TextRun({
                          text: "  static const int rateLimit = 3; // req per second",
                          size: 20,
                          font: "Courier New",
                          color: "94A3B8",
                        }),
                      ],
                    }),
                    new Paragraph({
                      children: [
                        new TextRun({
                          text: "  static const int pageSize = 25;",
                          size: 20,
                          font: "Courier New",
                          color: "86EFAC",
                        }),
                      ],
                    }),
                    new Paragraph({
                      children: [
                        new TextRun({
                          text: "}",
                          size: 20,
                          font: "Courier New",
                          color: "E2E8F0",
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
          ],
        }),
        pageBreak(),

        // ─── 12. DANH GIA ─────────────────────────────────────────
        h1("12. Tiêu chí đánh giá và điểm số"),
        new Table({
          width: { size: 9026, type: WidthType.DXA },
          columnWidths: [4000, 2400, 2626],
          rows: [
            makeHeaderRow(
              ["Tiêu chí", "Triển khai trong dự án", "Mức độ đáp ứng"],
              [4000, 2400, 2626],
            ),
            makeRow(
              [
                "UI/UX responsive, đẹp mắt",
                "Material 3, Hero anim, SliverAppBar",
                "Đầy đủ",
              ],
              [4000, 2400, 2626],
              false,
            ),
            makeRow(
              ["Light / Dark mode", "ThemeData + SharedPreferences", "Đầy đủ"],
              [4000, 2400, 2626],
              true,
            ),
            makeRow(
              ["Form có validation", "Tìm kiếm, đánh giá, ghi chú", "Đầy đủ"],
              [4000, 2400, 2626],
              false,
            ),
            makeRow(
              [
                ">=3 màn hình, navigation",
                "6 màn hình + go_router",
                "Vượt yêu cầu",
              ],
              [4000, 2400, 2626],
              true,
            ),
            makeRow(
              ["State management", "Riverpod Providers", "Đầy đủ"],
              [4000, 2400, 2626],
              false,
            ),
            makeRow(
              [
                "Xử lý async / loading",
                "FutureProvider, debounce, skeleton",
                "Đầy đủ",
              ],
              [4000, 2400, 2626],
              true,
            ),
            makeRow(
              ["REST API", "Jikan API v4 - 6 endpoints", "Đầy đủ"],
              [4000, 2400, 2626],
              false,
            ),
            makeRow(
              [
                "Cơ sở dữ liệu local",
                "sqflite - 3 bảng, CRUD đầy đủ",
                "Đầy đủ",
              ],
              [4000, 2400, 2626],
              true,
            ),
            makeRow(
              [
                "Tính năng nâng cao",
                "fl_chart + Hero animation + Offline",
                "Nhiều hơn yêu cầu",
              ],
              [4000, 2400, 2626],
              false,
            ),
          ],
        }),
        space(200),

        h2("12.1. Điểm mạnh của dự án"),
        bullet(
          "Jikan API hoàn toàn miễn phí, không cần đăng ký, dữ liệu phong phú (25.000+ anime)",
        ),
        bullet(
          "Poster anime đẹp tự nhiên - Hero animation và cached_image tạo ấn tượng mạnh",
        ),
        bullet(
          "Dễ thuyết trình: đề tài quen thuộc với sinh viên, demo trực quan",
        ),
        bullet(
          "Nhiều tính năng nâng cao có thể chọn thêm tùy sức (Firebase sync, notification, ...)",
        ),
        space(100),

        h2("12.2. Những lưu ý khi triển khai"),
        bullet(
          "Phải xử lý debounce khi gọi API tìm kiếm để tránh bị block (rate limit 3 req/s)",
        ),
        bullet(
          "Một số trường API có thể trả về null (poster, episodes) - cần xử lý null safety",
        ),
        bullet(
          "Pagination: API trả về 25 kết quả/trang - nên implement infinite scroll",
        ),
        bullet("Cache ảnh poster để app dùng được offline và load nhanh hơn"),
        space(200),

        para("---", { color: TEXT_GRAY, align: AlignmentType.CENTER }),
        para(
          "Tài liệu này được tạo tự động bởi công cụ hỗ trợ dự án Flutter.",
          { color: TEXT_GRAY, align: AlignmentType.CENTER },
        ),
        para("Phiên bản 1.0.0  |  2025", {
          color: TEXT_GRAY,
          align: AlignmentType.CENTER,
        }),
      ],
    },
  ],
});

Packer.toBuffer(doc).then((buffer) => {
  fs.writeFileSync("./AnimeTracker_TaiLieuDuAn.docx", buffer);
  console.log("Xuất file thành công: AnimeTracker_TaiLieuDuAn.docx");
});
