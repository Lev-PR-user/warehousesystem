class ProductCategoriesVaidator{

    static CategoryValid(CategoryData){
        const { name } = CategoryData;

        if(!name){
            throw new Error('Name field is required');
        }

        if(name.length < 1 || name.length > 100){
            throw new Error('Name must be between 1 and 100 characters');
        }
    };

    static CategoryFind(CategoryData){
        const { category_id } = CategoryData;
        if(!category_id){
            throw new Error('category id not found')
        };

        return true;
    };
}

module.exports = ProductCategoriesVaidator;