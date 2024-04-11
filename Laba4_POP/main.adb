with Philosopher;           use Philosopher;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Exceptions;        use Ada.Exceptions;
with GNAT.Semaphores;       use GNAT.Semaphores;
with Ada.Strings;           use Ada.Strings;

procedure Main is

    Philosopher_Array : array (1 .. Philosopher.GetCount) of Philosopher.Philosopher;
    Forks :
       array
          (1 .. Philosopher.GetCount) of Counting_Semaphore (1, Default_Ceiling);
    Philosopher_Index  : Integer;
    Waiter : Counting_Semaphore(4, Default_Ceiling);

    procedure Dinning
       (Philosopher_Index   : out Philosopher.Philosopher; 
        Delay_Second        : Duration := 0.5)
    is
    begin
        Waiter.Seize;

        Forks (Philosopher_Index.Left_Fork_Id).Seize;
            Put_Line
               ("The left fork was tooken philosopher " &
                Philosopher_Index.Id'Img & ".");


        Forks (Philosopher_Index.Right_Fork_Id).Seize;
            Put_Line
               ("The right fork was tooken philosopher " &
                Philosopher_Index.Id'Img & ".");

        delay Delay_Second;

        Forks (Philosopher_Index.Left_Fork_Id).Release;
            Put_Line
               ("The left fork was putten philosopher " &
                Philosopher_Index.Id'Img & ".");

        Forks (Philosopher_Index.Right_Fork_Id).Release;
            Put_Line
               ("The right fork was putten philosopher " &
                Philosopher_Index.Id'Img & ".");

        Waiter.Release;

    end Dinning;

    task type Philosopher_Manager is 
        entry Start(Philosopher_Index: Philosopher.Philosopher);
    end Philosopher_Manager;

    task body Philosopher_Manager is
        Philosopher_Index: Philosopher.Philosopher;
    begin
        accept Start (Philosopher_Index: Philosopher.Philosopher) do
            Philosopher_Manager.Philosopher_Index := Philosopher_Index;
        end Start;
        
        for I in 1 .. 10 loop    
            Dinning (Philosopher_Manager.Philosopher_Index);
        end loop;
    end Philosopher_Manager;

    Philosophers: array (1 .. Philosopher.GetCount) of Philosopher_Manager;
begin
    for I in Philosophers'Range loop
        Philosophers(I).Start (Philosopher_Array(I));
    end loop;

exception
    when e : Constraint_Error =>
        Put_Line
           ("[!] Divide by zero exception. Set another number of Philosophers (> 0).");

end Main;
