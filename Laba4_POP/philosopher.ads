package Philosopher is
    pragma Elaborate_Body;

    type States_Behaviour is (Eating, Hungry, Thinking);

    function IncId return Integer;
    function GetLastId return Integer;
    procedure SetCount (Num : Integer);
    function GetCount return Integer;

    type Philosopher is record
        Id            : Integer := GetLastId;
        Left_Fork_Id  : Integer := GetLastId;
        Right_Fork_Id : Integer := IncId; 
        State         : States_Behaviour  := Thinking;
    end record;

private
    Id              : Integer := 1;
    Philosopher_Count : Integer := 5;
end Philosopher;
