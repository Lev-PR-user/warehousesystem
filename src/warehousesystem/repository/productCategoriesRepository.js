const sequelize  = require(`../config/db`);

class ProductCategoriesRepository{

    async FindCategoryID(category_id){
        const result = await sequelize.models.product_categories.findOne({
        where: {category_id}
       });
       return result;
    };

    async GetCategoryByName(name){
        const result = await sequelize.models.product_categories.findOne({
        where: {name}
       });
       return result;
    };

    async CreateCategory(CategoryData){
        const { name } = CategoryData;

        const result = await sequelize.models.product_categories.create({
            name
        });
        return result;
    };

    async GetCategoriesAll(){
        const result = await sequelize.models.product_categories.findAll({
            order: [['name', 'ASC']],
        });

        return result;
    };

    async UpdateCategoryById(category_id, CategoryData){
    
    await sequelize.models.product_categories.update(CategoryData, {
        where: { category_id  }
    });
    
    const updatedCategory = await sequelize.models.product_categories.findOne({
        where: { category_id  }
    });
    
    return updatedCategory;
    };

    async DeleteCategory(category_id){
        const result = await sequelize.models.product_categories.destroy({
            where: {category_id}
        });
        
        return result;
    };
}

module.exports = new ProductCategoriesRepository();