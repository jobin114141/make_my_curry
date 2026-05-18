
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/product_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/web_product_shimmer_widget.dart';
import 'package:flutter_grocery/features/category/widgets/category_item_widget.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/product/widgets/category_cart_title_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryId;
  final String? subCategoryName;
  const
  CategoryProductScreen({super.key,required this.categoryId, this.subCategoryName});

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {

  void _loadData(BuildContext context) async {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if (categoryProvider.selectedCategoryIndex == -1) {

      categoryProvider.getCategory(int.tryParse(widget.categoryId), context);

      categoryProvider.getSubCategoryList(context, widget.categoryId);

      categoryProvider.initCategoryProductList(widget.categoryId);
    }
  }

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    String? appBarText = 'Sub Categories';
    if(widget.subCategoryName != null && widget.subCategoryName != 'null') {
      appBarText = widget.subCategoryName;
    }else{
      appBarText =  categoryProvider.categoryModel?.name ?? 'name';
    }
    categoryProvider.initializeAllSortBy(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : CustomAppBarWidget(
        title: appBarText,
        isCenter: false, isElevation: true,fromCategory: true,
      )) as PreferredSizeWidget?,
      body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    height: constraints.maxHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Sidebar (Subcategories) - Text Only
                        Container(
                          width: ResponsiveHelper.isDesktop(context) ? 120 : 80,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              right: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
                            ),
                          ),
                          child: categoryProvider.subCategoryList != null ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: categoryProvider.subCategoryList!.length + 1,
                            itemBuilder: (context, index) {
                              bool isAll = index == 0;
                              int actualIndex = index - 1;
                              bool isSelected = isAll
                                  ? categoryProvider.selectedCategoryIndex == -1
                                  : categoryProvider.selectedCategoryIndex == actualIndex;
                              String title = isAll
                                  ? getTranslated('all', context)
                                  : (categoryProvider.subCategoryList?[actualIndex].name ?? '');

                              return InkWell(
                                onTap: () {
                                  categoryProvider.onChangeSelectIndex(isAll ? -1 : actualIndex);
                                  categoryProvider.initCategoryProductList(
                                      isAll ? widget.categoryId : '${categoryProvider.subCategoryList![actualIndex].id}');
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    border: isSelected ? Border(
                                      left: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 3,
                                      ),
                                    ) : null,
                                  ),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: isSelected
                                        ? poppinsSemiBold.copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context).primaryColor,
                                            height: 1.3,
                                          )
                                        : poppinsRegular.copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.65),
                                            height: 1.3,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ) : const _SubcategoryTitleShimmerVertical(),
                        ),

                        // Right Side (Products Grid & Sort)
                        Expanded(
                          child: Column(
                            children: [
                              if (ResponsiveHelper.isDesktop(context))
                                Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(getTranslated('sort_by', context), style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      PopupMenuButton(
                                        elevation: 20,
                                        enabled: true,
                                        icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        onSelected: (dynamic value) {
                                          int index = categoryProvider.allSortBy.indexOf(value);
                                          categoryProvider.sortCategoryProduct(index);
                                        },
                                        itemBuilder: (context) {
                                          return categoryProvider.allSortBy.map((choice) {
                                            return PopupMenuItem(
                                              value: choice,
                                              child: Text(getTranslated(choice, context)),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              Expanded(
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: categoryProvider.subCategoryProductList.isNotEmpty ? Center(
                                        child: SizedBox(
                                          width: Dimensions.webScreenWidth,
                                          child: GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 8,
                                              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 8,
                                              childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1 / 1.4) : ResponsiveHelper.isTab(context) ? (1 / 1.6) : (1 / 1.8),
                                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: categoryProvider.subCategoryProductList.length,
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context, int index) {
                                              return ProductWidget(product: categoryProvider.subCategoryProductList[index], isCenter: true, isGrid: true);
                                            },
                                          ),
                                        ),
                                      ) : Center(
                                        child: SizedBox(
                                          width: Dimensions.webScreenWidth,
                                          child: (categoryProvider.hasData ?? false) ? const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                            child: _ProductShimmer(isEnabled: true),
                                          ) : NoDataWidget(isFooter: false, title: getTranslated('not_product_found', context)),
                                        ),
                                      ),
                                    ),
                                    const FooterWebWidget(footerType: FooterType.sliver),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            );
          }
      ),
    );
  }
}

class _SubcategoryTitleShimmerVertical extends StatelessWidget {
  const _SubcategoryTitleShimmerVertical();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 8,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: ColorResources.getGreyColor(context),
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductShimmer extends StatelessWidget {
  final bool isEnabled;

  const _ProductShimmer({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 8,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 8,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : ResponsiveHelper.isTab(context) ? (1/1.6) : (1/1.8),
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => const WebProductShimmerWidget(isEnabled: true),
      itemCount: 20,
    );
  }
}
