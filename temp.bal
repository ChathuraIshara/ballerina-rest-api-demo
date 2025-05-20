import ballerina/io;

const name = "hello";

type MapArray map<string>[];

function sayHello() {
    io:println("Hello world");
}

enum Color {
    RED,
    GREEN,
    BLUE
}

function add(int a, int b) returns int|error {
    if a < 0 {
        return error("error");
    }
    else if b > 10 {
        return error("error");
    }

    foreach int i in 0...a {
        io:println(i);
    }

    return a + b;
}
