import PDFKit


class ExportManager {
    static func generatePDF(healthData: [String: Any], completion: @escaping (URL?) -> Void) {
        // Create a PDF document
        let pdfDocument = PDFDocument()

        // Create a blank page size (US Letter dimensions)
        let pageWidth: CGFloat = 612 // Points
        let pageHeight: CGFloat = 792 // Points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        // Create a PDF page
        let pdfPage = PDFPage()
        let context = UIGraphicsGetCurrentContext()

        // Draw content on the page
        if let context = context {
            context.setFillColor(UIColor.white.cgColor)
            context.fill(pageRect)

            let text = """
            Health Report
            Steps: \(healthData["Steps"] ?? "N/A")
            Heart Rate: \(healthData["HeartRate"] ?? "N/A")
            Sleep: \(healthData["Sleep"] ?? "N/A")
            """

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            text.draw(in: CGRect(x: 50, y: 700, width: pageWidth - 100, height: 100), withAttributes: attributes)
        }

        // Add the page to the document
        pdfDocument.insert(pdfPage, at: 0)

        // Save to a temporary directory
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("HealthReport.pdf")
        if pdfDocument.write(to: fileURL) {
            completion(fileURL)
        } else {
            completion(nil)
        }
    }
}
