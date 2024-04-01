with Ada.Text_IO;
use Ada.Text_IO;

with GNAT.Semaphores;
use GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Producer_Consumer is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer) is
      Storage : List;
      Storage_Capacity : Integer := 0;
      pragma Atomic(Storage_Capacity);

      Full_Storage : Counting_Semaphore (Storage_Size, Default_Ceiling);

      task Producer;
      task Consumer;

      task body Producer is
         procedure Producer_Task is
         begin
            for i in 1 .. Item_Numbers loop
               Full_Storage.Seize;
               while Storage_Capacity = Storage_Size loop
                  delay 1.0;
               end loop;

               Storage.Append ("item " & i'Img);
               Put_Line ("Put item " & i'Img);
               Storage_Capacity := Storage_Capacity + 1;

               delay 1.5;
            end loop;
         end Producer_Task;
      begin
         Producer_Task;
      end Producer;

      task body Consumer is
         procedure Consumer_Task is
         begin
            for i in 1 .. Item_Numbers loop
               while Storage_Capacity = 0 loop
                  delay 1.0;
               end loop;

               declare
                  Item : String := First_Element (Storage);
               begin
                  Put_Line ("Took " & Item);
                  Storage_Capacity := Storage_Capacity - 1;
               end;

               Storage.Delete_First;
               Full_Storage.Release;

               delay 2.0;
            end loop;
         end Consumer_Task;
      begin
         Consumer_Task;
      end Consumer;
   begin
      null;
   end Starter;

begin
   Starter (3, 10);
end Producer_Consumer;
