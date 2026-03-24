function isValidUrl(value) {
    if (!value) return true; 
    try {
        new URL(value);
        return true;
    } catch {
        return false;
    }
}

class ProductValidator{

    static ProductValid(ProductData){
        const { name, description, price, category_id, image_url, is_available } = ProductData;

        if(!name || !price || !category_id || !is_available){
            throw new Error('Are fields is required');
        };

        if(!price && price !== 0){
            throw new Error('Product price is required');
        };

        if(!category_id){
            throw new Error('Category ID is required');
        };

        if(is_available === undefined || is_available === null){
            throw new Error('Availability status is required');
         };

        if(name.length < 1 || name.length > 100){
            throw new Error('Name must be between 1 and 100 characters');
        };

        if(price < 0){
            throw new Error('Price cannot be negative');
        };

        if(price > 1000000){
            throw new Error('Price is too high');
        };

        if(description && description.length > 1000){
            throw new Error('Description cannot exceed 1000 characters');
        };

        if(image_url && !isValidUrl(image_url)){
            throw new Error('Invalid image URL format');
        };

    function isValidUrl(value) {
        if (!value) return true; 
        try {
             new URL(value);
                return true;
            } catch {
                return false;
            }
        }
    return true;    
    };

    static ProductFind(ProductData){
        const { product_id } = ProductData;
        if(!product_id){
            throw new Error('Product id not found')
        };

        return true;
    };
}

module.exports = ProductValidator;