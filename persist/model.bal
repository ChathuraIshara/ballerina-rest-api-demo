type Employee record {
    int id;
    string name;
    decimal salary;
};

type Department record {
    int id;
    string name;
    Employee[] employees;
};
