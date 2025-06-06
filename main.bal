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

// Function to retrieve book from the table
function findBookById(string id) returns Book?|error {
    return booksTable[id];
}

service /book on bookListener {

    resource function get .() returns Book[] {
        return booksTable.toArray();
    }

    resource function get [string id]() returns Book|NotFoundIdError {
        // Step 1: Call a function
        Book?|error result = findBookById(id);

        // Step 2: Check result and respond
        if result is Book {
            return result;
        } else {
            return { body: "Id not found. Provided: " + id };
        }
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
