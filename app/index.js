const express = require("express")
const mongoose = require("mongoose")
var cors = require('cors')

const app = express();
app.use(express.json());
app.use(cors());
mongoose.set('strictQuery', true);

var mongo_user = process.env.MONGO_USER || "mongoadmin";
var mongo_password = process.env.MONGO_PASSWORD || "secret";
var mongo_ip = process.env.MONGO_IP || "mongodb";
var mongo_port = process.env.MONGO_PORT || 27017;


const mongoURL = `mongodb://${mongo_user}:${mongo_password}@${mongo_ip}:${mongo_port}/notedb?authSource=admin`;

app.get("/", (req, res) => {
    res.send('<p> Hello Api </p>')
})

// NoteSchema
const NoteSchema = new mongoose.Schema({
    note: {
        type: String,
        required: true,
    }
});

const Note = mongoose.model("Note", NoteSchema)

// get all notes
app.get("/notes", async (req, res) => {
    try {
        const notes = await Note.find();
        res.send({ notes })
    } catch (e) {
        console.log(e);
        res.status(400).json({ error: e.message });
    }
});

// create note 
app.post("/note", async (req, res) => {
    console.log(req.body);
    try {
        const note = new Note(req.body)
        await note.save()
        res.send(note)
    } catch (e) {
        console.log(e);
        return res.status(400).json({ status: "fail" });
    }
});

// check connection
mongoose
    .connect(mongoURL, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    })
    .then(() => {
        console.log("Successfully connected to DB");
        app.listen(3000, () => console.log("Server is listening on PORT 3000"));
    })
    .catch((e) => {
        console.log("Error in mongo db connection");
        console.log(mongoURL);
        console.log(e);
        process.exit(1);
    });
