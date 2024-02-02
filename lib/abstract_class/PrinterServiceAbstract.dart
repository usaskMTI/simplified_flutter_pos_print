abstract class PrinterServiceAbstract {
  Future<void> generateAndPrintReceipt();
  Future<void> printReceiptJson(String orderJson);
}
