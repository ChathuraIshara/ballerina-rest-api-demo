import ballerina/http;
import ballerina/uuid;
import ballerinax/mongodb;

configurable string host = "localhost";
configurable int port = 27017;

mongodb:Client mongoDB = check new (config = {
    connection: {
        serverAddress: {
            host: host,
            port: port
        }
    }
});

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

service /book on bookListener {

    private final mongodb:Database booksDb;

    function init() returns error? {
        self.booksDb = check mongoDB->getDatabase("sample");
    }

    resource isolated function get .() returns Book[]|error {
        mongodb:Collection books = check self.booksDb->getCollection("books");

        stream<Book, error?> findResult = check books->find();

        return from Book b in findResult
            select b;
    }

    resource isolated function get [string id]() returns Book|NotFoundIdError|error {
        mongodb:Collection books = check self.booksDb->getCollection("books");

        Book|mongodb:DatabaseError|mongodb:ApplicationError|error? findResult = check books->findOne({id});

        if findResult is () {
            return {
                body: "Id not found. Provided:" + id
            };
        }

        return findResult;
    }

    resource isolated function post .(BookRequest bookRequest) returns string|error {
        mongodb:Collection books = check self.booksDb->getCollection("books");

        string id = uuid:createType1AsString();
        Book newBook = {id, ...bookRequest};

        check books->insertOne(newBook);

        return "New book added successfully";
    }

    resource isolated function put [string id](BookRequest bookRequest) returns string|NotFoundIdError|error {
        mongodb:Collection books = check self.booksDb->getCollection("books");

        mongodb:UpdateResult updateResult = check books->updateOne({id}, {set: bookRequest});

        if updateResult.modifiedCount != 1 {
            return {
                body: "Id not found => " + id
            };
        }

        return "Book updated successsfully!";
    }

    resource isolated function delete [string id]() returns string|NotFoundIdError|error {
        mongodb:Collection books = check self.booksDb->getCollection("books");

        mongodb:DeleteResult deleteResult = check books->deleteOne({id});

        if deleteResult.deletedCount != 1 {
            return {
                body: "Id not found => " + id
            };
        }

        return "Book deleted successsfully!";
    }

}

