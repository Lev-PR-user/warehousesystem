const sequelize  = require(`../config/db`);

class ProductRepository{

    async FindProductID(product_id){
        const result = await sequelize.models.products.findByPk(product_id);
        return result;
    };

    async GetProductByName(name){
        const result = await sequelize.models.products.findOne({
            where: {name}
        });
        return result;
    };

    async CreateProduct(ProductData){
        const result = await sequelize.models.products.create(ProductData);
        return result;
    };

    async GetProductsAll(){
        const result = await sequelize.models.products.findAll({
            order: [['name', 'ASC']],
        });
        return result;
    };

    async UpdateProductById(product_id, ProductData){
        const result = await sequelize.models.products.update(ProductData, {
            where: { product_id },
            returning: true
        });
        
        return result[1]?.[0] || null;
    };

    async DeleteProduct(product_id){
        const result = await sequelize.models.products.destroy({
            where: {product_id}
        });
        return result > 0;
    };
}

module.exports = new ProductRepository();