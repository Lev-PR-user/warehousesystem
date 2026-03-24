const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  
  {
    host: process.env.DB_HOST,
    dialect: 'postgres', 
    logging: false, 
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);
sequelize.authenticate()
  .then(() => {
    console.log('Соединение с базой данных успешно установлено');
  })
  .catch(error => {
    console.error('Невозможно подключиться к базе данных:', error.message);
  });

module.exports = sequelize;