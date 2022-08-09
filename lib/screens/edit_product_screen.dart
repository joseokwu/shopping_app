import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen();

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', description: '', imageUrl: '', title: '', price: 0);
  // var urlPattern =
  //     r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocus.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      print(productId);
      if (productId != null) {
        final existingProduct = Provider.of<Products>(context, listen: false)
            .getProductById(productId);
        if (existingProduct != null) {
          _editedProduct = Product(
              id: existingProduct.id,
              description: existingProduct.description,
              // imageUrl: existingProduct.imageUrl,
              title: existingProduct.title,
              price: existingProduct.price,
              isFavorite: existingProduct.isFavorite);
          _imageUrlController.text = existingProduct.imageUrl;
        }
      }
      _isInit = false;

      // TODO: implement didChangeDependencies
      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocus.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final errorFree = _form.currentState.validate();
    if (!errorFree) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id.length > 0) {
      try {
        await Provider.of<Products>(context, listen: false)
            .editProduct(_editedProduct.id, _editedProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('An error occurred'),
              content: Text('Something went wrong, please try again later'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            );
          },
        );
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('An error occurred'),
              content: Text('Something went wrong, please try again later'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            );
          },
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocus.hasFocus) {
      if (!_imageUrlController.text.endsWith('.jpg') &&
          !_imageUrlController.text.endsWith('.jpeg') &&
          !_imageUrlController.text.endsWith('.png')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _editedProduct.id.length > 0 ? 'Edit Product' : 'Add Product'),
          actions: [
            IconButton(
              onPressed: _submitForm,
              icon: Icon(Icons.save),
            ),
          ]),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(children: [
                    TextFormField(
                      initialValue: _editedProduct.title,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocus),
                      onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          title: newValue,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.price.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocus,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocus),
                      onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                          price: double.parse(newValue),
                          isFavorite: _editedProduct.isFavorite),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Only numbers allowed';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please put a valid price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocus,
                      onSaved: (newValue) => _editedProduct = Product(
                          id: _editedProduct.id,
                          description: newValue,
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a description';
                        }
                        if (value.length <= 10) {
                          return 'Description should be more than 10 words';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter Url')
                              : Image.network(
                                  _imageUrlController.text,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocus,
                            onFieldSubmitted: (_) => _submitForm(),
                            // onEditingComplete: () {
                            //   setState(() {});
                            // },
                            onSaved: (newValue) => _editedProduct = Product(
                                id: _editedProduct.id,
                                description: _editedProduct.description,
                                imageUrl: newValue,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                isFavorite: _editedProduct.isFavorite),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide an image URL';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.png')) {
                                return 'Please use Jpg, Jpeg ot Png formats';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ),
            ),
    );
  }
}
