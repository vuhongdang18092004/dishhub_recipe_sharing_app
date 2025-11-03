/// Tách các chuỗi, chuyển thành chữ thường, và loại bỏ trùng lặp.
List<String> generateKeywords(
    String title, List<String> ingredients, List<String> tags) {
      
  // Dùng Set (tập hợp) để tự động loại bỏ các từ trùng lặp
  final Set<String> keywords = {};

  // 1. Thêm từ từ Tên công thức (title)
  // Tách các từ bằng khoảng trắng
  final nameWords = title.toLowerCase().split(' ');
  keywords.addAll(nameWords);

  // 2. Thêm từ từ Nguyên liệu (ingredients)
  for (final ingredient in ingredients) {
    final ingredientWords = ingredient.toLowerCase().split(' ');
    keywords.addAll(ingredientWords);
  }

  // 3. Thêm từ từ Thẻ (tags)
  for (final tag in tags) {
    final tagWords = tag.toLowerCase().split(' ');
    keywords.addAll(tagWords);
  }

  // Loại bỏ các từ rỗng (trường hợp có 2 khoảng trắng liên tiếp)
  keywords.removeWhere((word) => word.isEmpty);

  // Chuyển Set thành List (danh sách) và trả về
  return keywords.toList();
}