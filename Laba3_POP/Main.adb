with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Producer_Consumer is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer) is
      Storage : List;
      Storage_Capacity : Integer := 0;

      Full_Storage : Counting_Semaphore (Storage_Size, Default_Ceiling);

      task Producer;
      task Consumer;

      task body Producer is
      begin
         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            loop
               pragma Unroll(1);
               exit when Storage_Capacity < Storage_Size;
               delay 1.0;
            end loop;

            Storage.Append ("item " & Integer'Image(i));
            Put_Line ("Put item " & Integer'Image(i));
            Storage_Capacity := Storage_Capacity + 1;

            delay 1.5;
         end loop;
      end Producer;

      task body Consumer is
      begin
         for i in 1 .. Item_Numbers loop
            loop
               pragma Unroll(1);
               exit when Storage_Capacity > 0;
               delay 1.0;
            end loop;

            declare
               Item : constant String := First_Element (Storage);
            begin
               Put_Line ("Took " & Item);
               Storage_Capacity := Storage_Capacity - 1;
            end;

            Storage.Delete_First;
            Full_Storage.Release;

            delay 2.0;
         end loop;
      end Consumer;
   begin
      null; -- Placeholder for future initialization logic
   end Starter;

begin
   Starter (3, 10);
end Producer_Consumer;
