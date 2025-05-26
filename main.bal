import ballerina/http;
import ballerina/uuid;

type Book record {| 
    readonly string id; 
    *BookRequest; 
|};

type BookRequest record {| 
    string name; 
    string author; 
    int year; 
|};

type NotFoundIdError record {| 
    *http:NotFound; 
    string body; 
|};

listener http:Listener bookListener = new (9090);

// In-memory table to store books
table<Book> key(id) booksTable = table [];

// Helper function to get a book by ID
function getBookById(string id) returns Book|NotFoundIdError {
    Book? book = booksTable[id];
    if book is Book {
        return book;
    }
    return { body: "Id not found. Provided: " + id };
}

service /book on bookListener {

    resource function get .() returns Book[] {
        return booksTable.toArray();
    }

    resource function get [string id]() returns Book|NotFoundIdError {
        return getBookById(id);
    }

    resource function post .(BookRequest bookRequest) returns string {
        string id = uuid:createType1AsString();
        Book newBook = { id, ...bookRequest };

        booksTable.add(newBook);
        return "New book added successfully";
    }

    resource function put [string id](BookRequest bookRequest) returns string|NotFoundIdError {
        if booksTable.hasKey(id) {
            booksTable.put({ id, ...bookRequest });
            return "Book updated successfully!";
        }
        return { body: "Id not found => " + id };
    }

    resource function delete [string id]() returns string|NotFoundIdError {
        if booksTable.hasKey(id) {
            _ = booksTable.remove(id);
            return "Book deleted successfully!";
        }
        return { body: "Id not found => " + id };
    }
}
