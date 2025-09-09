//import the express module
const express = require('express');
const helloRoute = require('./routes/hello.js');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const bcrypt = require('bcryptjs');


//Defind the port number the server will listen on 
const PORT = 3000;
//create an instance of an express application
//because it give us the starting point
const app = express();
//mongodb string 
const DB = "mongodb+srv://voyennhi0703:nhivo1234567@cluster0.txkyxby.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
//middleware - to register routes or to moutn route
app.use(express.json());
app.use(authRouter);
app.use(helloRoute);

mongoose.connect(DB).then(() => {
    console.log('MongoDB Connected');
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server started on port ${PORT}`);
});

