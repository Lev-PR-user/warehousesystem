const { DataTypes } = require("sequelize");

async function CreateTables(sequelize) {
    try {
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
        ProductCategories.hasMany(Products, { foreignKey: 'category_id' });
        Products.belongsTo(ProductCategories, { foreignKey: 'category_id' });

        await seedData(users, ProductCategories, Products);


        await sequelize.sync({ force: false  }); 
        console.log('All tables for warehousesystem created successfully');


    } catch (error) {
        console.error('Error creating tables:', error.message);
        throw error;
    }
}

async function seedData(users, ProductCategories, Products) {

    const categories = await ProductCategories.bulkCreate([
        { name: 'Молочные продукты' },
        { name: 'Хлебобулочные изделия' },
        { name: 'Напитки' },
        { name: 'Овощи и фрукты' }
    ]);

    const products = await Products.bulkCreate([
        {
            name: 'Молоко "Домик в деревне"',
            description: 'Пастеризованное молоко 3.2%, 1 литр',
            price: 89.99,
            category_id: categories[0].category_id,
            quantity: 50,
            is_available: true
        },
        {
            name: 'Кефир "Простоквашино"',
            description: 'Кефир 2.5%, 500 мл',
            price: 65.50,
            category_id: categories[0].category_id,
            quantity: 35,
            is_available: true
        },
        {
            name: 'Сыр "Российский"',
            description: 'Полутвёрдый сыр 50%, 200 г',
            price: 159.90,
            category_id: categories[0].category_id,
            quantity: 20,
            is_available: true
        },
        {
            name: 'Хлеб "Бородинский"',
            description: 'Ржаной хлеб с кориандром, 350 г',
            price: 55.00,
            category_id: categories[1].category_id,
            quantity: 100,
            is_available: true
        },
        {
            name: 'Батон "Нарезной"',
            description: 'Пшеничный батон, 300 г',
            price: 42.00,
            category_id: categories[1].category_id,
            quantity: 80,
            is_available: true
        },
        {
            name: 'Вода "Святой источник"',
            description: 'Питьевая вода негазированная, 1.5 л',
            price: 35.99,
            category_id: categories[2].category_id,
            quantity: 200,
            is_available: true
        },
        {
            name: 'Сок "Добрый" апельсиновый',
            description: 'Сок восстановленный, 1 л',
            price: 99.99,
            category_id: categories[2].category_id,
            quantity: 45,
            is_available: true
        },
        {
            name: 'Яблоки "Голден"',
            description: 'Сладкие яблоки, 1 кг',
            price: 120.00,
            category_id: categories[3].category_id,
            quantity: 60,
            is_available: true
        },
        {
            name: 'Картофель',
            description: 'Молодой картофель, 1 кг',
            price: 45.00,
            category_id: categories[3].category_id,
            quantity: 150,
            is_available: true
        }
    ]);

    const bcrypt = require('bcryptjs');
    const hashedPassword = await bcrypt.hash('password123', 10);

    const usersList = await users.bulkCreate([
        {
            login: 'admin',
            phone: '+79001234567',
            email: 'admin@warehouse.ru',
            hashed_password: hashedPassword,
            role: 'admin',
            avatar_url: null
        },
        {
            login: 'ivan_kladovshik',
            phone: '+79112345678',
            email: 'ivan@warehouse.ru',
            hashed_password: hashedPassword,
            role: 'customer',
            avatar_url: null
        },
        {
            login: 'petr_manager',
            phone: '+79223456789',
            email: 'petr@warehouse.ru',
            hashed_password: hashedPassword,
            role: 'admin',
            avatar_url: null
        },
        {
            login: 'elena_sklad',
            phone: '+79334567890',
            email: 'elena@warehouse.ru',
            hashed_password: hashedPassword,
            role: 'customer',
            avatar_url: null
        }
    ]);
}

module.exports = CreateTables;