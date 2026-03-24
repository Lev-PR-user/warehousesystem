const ProductService = require('../service/productService');

class ProductsController{
    
    async CreateProduct(req, res){
        try { 
            const result = await ProductService.CreateProduct(req.body);
            res.status(201).json(result);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async GetProductsAll(req, res){
        try{
            const result = await ProductService.GetProductsAll(); 
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    }

    async GetProductByName(req, res){
        try{
            const { name }  = req.params;
            const result = await ProductService.GetProductByName(name); 
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    }

    async UpdateProduct(req, res){
        try{
            const { product_id } = req.params; 
            const result = await ProductService.UpdateProduct(product_id, req.body);
            res.status(200).json(result); 
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    }

    async DeleteProduct(req, res){
        try{
            const { product_id } = req.params; 
            const result = await ProductService.DeleteProduct(product_id); 
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    }
}

module.exports = new ProductsController();