const ProductCategoriesVaLidator = require('../validators/productCategoriesVaidator');
const ProductCategoriesRepository = require('../repository/productCategoriesRepository');

class ProductCategoriesService{

    async CreateCategory(CategoryData){

        ProductCategoriesVaLidator.CategoryValid(CategoryData);

        const existingcategory = await ProductCategoriesRepository.GetCategoryByName(CategoryData.name);
            if (existingcategory) {
                throw new Error('Name already exists');
            };

        const result = await ProductCategoriesRepository.CreateCategory({
            name: CategoryData.name
            });

        return result;
    };

    async GetCategoriesAll(name){
        
        const result = await ProductCategoriesRepository.GetCategoriesAll({
            name: name
        })
        return result;
    };

    async GetCategoryByName(name){
        ProductCategoriesVaLidator.CategoryValid({ name: name });
        const result = await ProductCategoriesRepository.GetCategoryByName(name);
        return result;
    };

    async UpdateCategory(category_id, CategoryData){    
        ProductCategoriesVaLidator.CategoryFind({ category_id });

        const category = await ProductCategoriesRepository.FindCategoryID(category_id);

        if(!category){
            throw new Error('Category not found')
        };

        const updatecategory = await ProductCategoriesRepository.UpdateCategoryById(category_id, CategoryData);
        return updatecategory;
    };

    async DeleteCategory(category_id){

        ProductCategoriesVaLidator.CategoryFind({ category_id });

        const category = await ProductCategoriesRepository.FindCategoryID(category_id);

        if(!category){
            throw new Error('Category not found')
        };

        await ProductCategoriesRepository.DeleteCategory(category_id);

        return {
            message: 'Category deleted successfully'
        };
    };
}

module.exports = new ProductCategoriesService();