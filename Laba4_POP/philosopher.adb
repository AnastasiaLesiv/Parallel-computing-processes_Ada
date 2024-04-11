with Philosopher;

package body Philosopher is
    function IncId return Integer is
    begin
        if GetCount <= 0 then
            raise Constraint_Error;
        end if;

        Id := Id rem GetCount + 1;
        return Id;
    end IncId;

    function GetLastId return Integer is
    begin
        return Id;
    end GetLastId;

    procedure SetCount (Num : Integer) is
    begin
        Philosopher_Count := Num;
    end SetCount;

    function GetCount return Integer is
    begin
        return Philosopher_Count;
    end GetCount;
end Philosopher;
