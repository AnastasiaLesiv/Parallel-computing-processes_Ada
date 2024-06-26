with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Bounded_Synchronized_Queues;
with Ada.Text_IO;

procedure Producer_Consumer_V1 is
   type Work_Item is range 1 .. 10;

   package Work_Item_Queue_Interfaces is
     new Ada.Containers.Synchronized_Queue_Interfaces
           (Element_Type => Work_Item);

   package Work_Item_Queues is
     new Ada.Containers.Bounded_Synchronized_Queues
           (Queue_Interfaces => Work_Item_Queue_Interfaces,
            Default_Capacity => 5);

   Queue : Work_Item_Queues.Queue;

   task type Producer;
   task type Consumer;

   Producers : array (1 .. 4)  of Producer;
   Consumers : array (1 .. 2) of Consumer;

   task body Producer is
   begin
      for Item in Work_Item loop
      Queue.Enqueue(Item);
         --Work_Item_Queues.Enqueue(Queue, New_Item => Item);
         Ada.Text_IO.Put_Line ("Producer put " & Work_Item'Image (Item));
      end loop;
   end Producer;

   task body Consumer is
      Item : Work_Item;
   begin
      loop
         select
            Queue.Dequeue(Item); -- Call the Dequeue entry of the Queue object
            Ada.Text_IO.Put_Line ("Consumer take " & Work_Item'Image (Item));
         or
            
            delay 1.0; -- Delay for 1 second if the queue is empty
            exit;
         end select;
      end loop;
      Ada.Text_IO.Put_Line ("Consumer stoped ");
   end Consumer;

begin
   null;
end Producer_Consumer_V1;
