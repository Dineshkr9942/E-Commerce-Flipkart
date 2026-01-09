import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Product Page.dart';

class categoryPage extends StatefulWidget {
  const categoryPage({super.key});

  @override
  State<categoryPage> createState() => _categoryPageState();
}

class _categoryPageState extends State<categoryPage> {
  List<String> categories = [];
  bool isLoading = true;

  final Map<String, String> categoryImages = {
    "beauty":
    "https://static.vecteezy.com/system/resources/previews/028/099/987/large_2x/beauty-cosmetic-makeup-product-brushes-lipstick-nail-polish-collection-on-white-background-generative-ai-free-photo.jpg",
    "fragrances":
    "https://cdn.pixabay.com/photo/2023/06/01/06/21/perfume-8032808_1280.jpg",
    "furniture":
    "https://modernwicker.com/cdn/shop/files/SouthSeaRattanNadineIndoorLivingRoomSetA_7a9216f3-1400-4430-b5ee-89a42f6c84b1.png?v=1725450396",
    "groceries":
    "https://tse4.mm.bing.net/th/id/OIP.94iWciyuW2UEDeSeqN8W_wAAAA?w=474&h=474&rs=1&pid=ImgDetMain&o=7&rm=3",
    "home-decoration":
    "https://hips.hearstapps.com/hmg-prod/images/homegoods-rental-1665542241.png?crop=0.660xw:0.935xh;0,0.0651xh&resize=640:*",
    "kitchen-accessories":
    "https://tse2.mm.bing.net/th/id/OIP.X-HWZiiwriCCL2-wXCIoiQHaHa?w=612&h=612&rs=1&pid=ImgDetMain&o=7&rm=3",
    "laptops":
    "https://tse1.explicit.bing.net/th/id/OIP.k98ua9po6mw6-xUt8qFOpQHaHa?w=626&h=626&rs=1&pid=ImgDetMain&o=7&rm=3",
    "mens-shirts":
    "https://i5.walmartimages.com/seo/JUMESG-Mens-Dress-Shirts-Mens-Dress-Shirts-Regular-Fit-Long-Sleeve-Stretch-Business-Dress-Shirts-for-Men-Blue-XXL_6160affd-fad5-4558-8d71-a4e2f17bda02.bc298ecc4e758a9721b3554b0c2031b6.jpeg",
    "mens-shoes":
    "https://down-my.img.susercontent.com/file/0f3fa0e79ac3240010dc88962326d975",
    "mens-watches":
    "https://cdn.shopify.com/s/files/1/1762/7203/products/SINOBI-2017-Mens-Watches-Top-Brand-Luxury-Business-Stainless-Steel-Quartz-Watch-Male-Sport-Chronograph-Clock_14cef2b0-9b99-4b59-92b4-20ec35f8a162_1024x1024.jpg?v=1583680494",
    "mobile-accessories":
    "https://m.media-amazon.com/images/I/71mW+sxdM+L._AC_.jpg",
    "motorcycle":
    "https://imgcdn.stablediffusionweb.com/2024/3/16/56bc2208-940a-441d-bcdc-e63cfcbec129.jpg",
    "skin-care":
    "https://flitit.com/cdn/shop/products/sunday-riley-beauty-sunday-riley-go-to-bed-with-me-complete-evening-routine-skincare-set-38532690346205_2048x2048.jpg?v=1670830450",
    "smartphones":
    "https://tse3.mm.bing.net/th/id/OIP.pjh1dumyzDFjM8q6Pwn8zQAAAA?rs=1&pid=ImgDetMain&o=7&rm=3",
    "sports-accessories":
    "https://tse2.mm.bing.net/th/id/OIP.jwfUcKdOyWhVmed73ww4VwHaHZ?w=2048&h=2046&rs=1&pid=ImgDetMain&o=7&rm=3",
    "sunglasses":
    "https://images-static.nykaa.com/media/catalog/product/tr:h-800,w-800,cm-pad_resize/7/6/766fb72PC001BU15V_1.jpg",
    "tablets":
    "https://cdn.shopify.com/s/files/1/0599/5413/5239/files/REGEN_-_iPad_Pro_12.9_-_5th_GEN_-_Hero_-_Space_Grey_480x480.jpg?v=1662703849",
    "tops":
    "https://tse4.mm.bing.net/th/id/OIP.ieUABopEoQ-Ta6uAHH_mFAAAAA?rs=1&pid=ImgDetMain&o=7&rm=3",
    "vehicle":
    "https://tse3.mm.bing.net/th/id/OIP.0datZNCNx4PDX48r5G2YpgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3",
    "womens-bags":
    "https://i5.walmartimages.com/seo/TAIAOJING-Women-Handbag-Roomy-Fashion-Handbags-Ladies-Purse-Satchel-Shoulder-Bags-Tote-Leather-Bag_818ee1c1-2372-4b3b-9907-540529dacf2d.081c23150ee4887ebc72db0f9ed65df6.jpeg",
    "womens-dresses":
    "https://i5.walmartimages.com/seo/Alvivi-Kids-Girls-Shiny-Party-Dress-Sequin-Lace-Jumpsuit-Overlay-Romper-6-16-Burgundy-14_6f751aad-b221-4d20-bb65-7d8169eabc08.386fef6118ba92b546f3def151219512.jpeg",
    "womens-jewellery":
    "https://th.bing.com/th/id/R.4aea12329f76bd36486da9a7082833b7?rik=PdNoh71YSdvefw&riu=http%3a%2f%2fblog.southindiajewels.com%2fwp-content%2fuploads%2f2018%2f02%2fgold-jewellery-sets-for-marriage-19.jpg&ehk=q9Tj80NdD0xrUQ1pHn9Q4cEcXVsGprUyKWwiyyOIDnw%3d&risl=&pid=ImgRaw&r=0",
    "womens-shoes":
    "https://thumbs.dreamstime.com/b/classic-red-high-heel-shoes-isolated-white-background-generative-ai-quality-illustration-306770181.jpg",
    "womens-watches":
    "https://th.bing.com/th/id/R.13f7153d79931238a818126638a0d34a?rik=FV0cOEuVW0H31A&riu=http%3a%2f%2fwww.wardrobemag.com%2fwp-content%2fuploads%2f2017%2f01%2fGeneva-Watches-for-Women.jpg&ehk=dMuGJXgB%2fPbOxdjbR%2fsfMWUckTqA%2fod3lrnydWNDyrw%3d&risl=&pid=ImgRaw&r=0",
  };

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http
        .get(Uri.parse("https://dummyjson.com/products/category-list"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        categories = data.map((e) => e.toString()).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String cat = categories[index];
            String img = categoryImages[cat] ??"No Image";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsPage(category: cat),
                  ),
                );
              },
              child: Card(
                color: Colors.white70,
                elevation: 8,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: 0.9,
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        cat.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Category Products Page

class CategoryProductsPage extends StatefulWidget {
  final String category;
  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    final response = await http.get(Uri.parse(
        "https://dummyjson.com/products/category/${widget.category}"));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      setState(() {
        products = body['products'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load products")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        backgroundColor: Colors.blue.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(child: Text("No products found"))
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => productPage(
                    id: item['id'],
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.white70,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      item['thumbnail'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      item['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      "₹${item['price']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
