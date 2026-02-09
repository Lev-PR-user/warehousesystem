const { DataTypes } = require("sequelize");

async function CreateTables(sequelize) {
    try {
            // Модель пользователей
        const users = sequelize.define('users', {
            user_id: {
                type: DataTypes.INTEGER,
                primaryKey: true, 
                autoIncrement: true,
                field: 'user_id'
            },
            login: {
                type: DataTypes.STRING,
                field: 'login'
            },
            phone: {
                type: DataTypes.STRING,
                allowNull: false,
                field: 'phone',
                validate: {
                    notEmpty: true,
                    is: {
                        args: /^\+7\d{10}$/,
                        msg: 'Phone must be in format +7XXXXXXXXXX'
                    }
                },
                unique: true
            },
            email: {
                type: DataTypes.STRING,
                allowNull: false,
                field: 'email',
                validate: {
                    isEmail: {
                        msg: 'Please provide a valid email address'
                    }
                },
                unique: true
            },
            hashed_password: {
                type: DataTypes.STRING,
                allowNull: false, 
                field: 'hashed_password',
                validate: {
                    notEmpty: true,
                    len: {
                        args: [6, 100],
                        msg: 'Password must be at least 6 characters long'
                    }
                }
            },
            avatar_url: {
                type: DataTypes.STRING,
                allowNull: true,
                field: 'avatar_url'
            },
            role: {
                type: DataTypes.ENUM('customer', 'admin' ),
                defaultValue: 'customer',
                field: 'role'
            },
            created_at: {
                type: DataTypes.DATE,
                defaultValue: DataTypes.NOW,
                field: 'created_at'
            }
        }, {
            tableName: 'users',
            timestamps: false, 
            underscored: true
        });
            // Модель категорий
        const ProductCategories = sequelize.define('product_categories', {
            category_id: {
                type: DataTypes.INTEGER,
                primaryKey: true, 
                autoIncrement: true,
                field: 'category_id'
            },
            name: {
                type: DataTypes.STRING,
                allowNull: false, 
                field: 'name',
                validate: {
                    notEmpty: true,
                    len: {
                        args: [1, 100],
                        msg: 'Category name must be between 1 and 100 characters'
                    }
                }
            },
        }, {
            tableName: 'product_categories',
            timestamps: false,
            underscored: true
        });
            // Модель товаров
        const Products = sequelize.define('products', {
            product_id: {
                type: DataTypes.INTEGER,
                primaryKey: true, 
                autoIncrement: true,
                field: 'product_id'
            },
            name: {
                type: DataTypes.STRING,
                allowNull: false, 
                field: 'name',
                validate: {
                    notEmpty: true,
                    len: {
                        args: [1, 100],
                        msg: 'Product name must be between 1 and 100 characters'
                    }
                }
            },
            description: {
                type: DataTypes.TEXT,
                allowNull: true, 
                defaultValue: null, 
                field: 'description'
            },
            price: {
                type: DataTypes.DECIMAL(10, 2),
                allowNull: false, 
                field: 'price',
                validate: {
                    min: {
                        args: [0],
                        msg: 'Price cannot be negative'
                    }
                }
            },
            category_id: {
                type: DataTypes.INTEGER,
                allowNull: false,
                field: 'category_id'
            },
            image_url: {
                type: DataTypes.STRING,
                allowNull: true,
                field: 'image_url'
            },
            quantity: {
                type: DataTypes.INTEGER,
                allowNull: true,
                field: 'quantity'
            },
            is_available: {
                type: DataTypes.BOOLEAN,
                defaultValue: true,
                allowNull: false, 
                field: 'is_available'
            }
        }, {
            tableName: 'products',
            timestamps: false,
            underscored: true
        });

        // Определение связей между таблицами
        ProductCategories.hasMany(Products, { foreignKey: 'category_id' });
        Products.belongsTo(ProductCategories, { foreignKey: 'category_id' });



        // Создание таблиц в БД
        await sequelize.sync({ force: false  }); 
        console.log('All tables for warehousesystem created successfully');


    } catch (error) {
        console.error('Error creating tables:', error.message);
        throw error;
    }
}

module.exports = CreateTables;