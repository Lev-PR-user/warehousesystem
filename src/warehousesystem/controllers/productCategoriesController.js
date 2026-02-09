const ProductCategoriesService = require('../service/productCategoriesService');

class ProductCategoriesController{
    async CreateCategory(req, res){
        try { 
        const result = await ProductCategoriesService.CreateCategory(req.body);
            res.status(201).json(result);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    };

    async GetCategoriesAll(req, res){
        try{
            const result = await ProductCategoriesService.GetCategoriesAll();
            res.status(200).json(result);
        }catch (error){
            res.status(400).json({ message: error.message });
        }
    };

    async GetCategoryByName(req, res){
        try{
        const { name }  = req.params;
        const result = await ProductCategoriesService.GetCategoryByName(name)
        res.status(200).json(result)
    }catch (error){
            res.status(400).json({ message: error.message });
        };
    };

    async UpdateCategory(req, res){
        try{
            const { category_id } = req.params;
            const result = await ProductCategoriesService.UpdateCategory(category_id, req.body);
            res.status(200).json(result); 
        }catch (error){
            res.status(400).json({ message: error.message });
        };
    };

    async DeleteCategory(req, res){
        try{
            const { category_id } = req.params;
            const result = await ProductCategoriesService.DeleteCategory(category_id);
            res.status(200).json(result);
        } catch (error){
            res.status(400).json({ message: error.message });
        }
    };

}

module.exports = new ProductCategoriesController();