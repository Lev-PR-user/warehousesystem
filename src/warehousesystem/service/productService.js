const ProductValidator = require('../validators/productValidator');
const ProductRepository = require('../repository/productRepository');

class ProductService{

    async CreateProduct(ProductData){
        ProductValidator.ProductValid(ProductData);

        await ProductRepository.GetProductByName(ProductData.name);
        const result = await ProductRepository.CreateProduct(ProductData);
        return result;
    }

    async GetProductsAll(){
        const result = await ProductRepository.GetProductsAll();
        return result;
    }

    async GetProductByName(name){
        const result = await ProductRepository.GetProductByName(name);
        return result;
    }

    async UpdateProduct(product_id, ProductData){    
        ProductValidator.ProductFind({ product_id });

        await ProductRepository.FindProductID(product_id);
        const updateProduct = await ProductRepository.UpdateProductById(product_id, ProductData);
        return updateProduct;
    }

    async DeleteProduct(product_id){
        ProductValidator.ProductFind({ product_id });

        await ProductRepository.FindProductID(product_id);
        await ProductRepository.DeleteProduct(product_id);
        return {
            message: 'Product deleted successfully'
        };
    }
}

module.exports = new ProductService();