with Ada.Text_IO; use Ada.Text_IO;

procedure thread_min_element is
   Dim : constant Integer := 340;
   Thread_Num : constant Integer := 11;
   Arr : array(1..Dim) of Integer;

   type Min_Element_Record is record
      Value : Integer;
      Index : Integer;
   end record;

   procedure Init_Arr is
   begin
      for I in Arr'Range loop
         if I = Dim / Thread_Num then
            Arr(I) := I * (-1);
         else
            Arr(I) := I;
         end if;
      end loop;
   end Init_Arr;

   function Part_Min_Element(Start_Index, Finish_Index : in Integer) return Min_Element_Record is
      Min_Element : Min_Element_Record := (Value => Arr(Start_Index), Index => Start_Index);
   begin
      for I in Start_Index + 1..Finish_Index loop
         if Arr(I) < Min_Element.Value then
            Min_Element := (Value => Arr(I), Index => I);
         end if;
      end loop;
      return Min_Element;
   end Part_Min_Element;

   task type Starter_Thread is
      entry Start(Start_Index, Finish_Index : in Integer);
   end Starter_Thread;

   protected Part_Manager is
      procedure Set_Part_Min_Element(Min_Element : in Min_Element_Record);
      entry Get_Min_Element(Min_Element : out Min_Element_Record);
   private
      Tasks_Count : Integer := 0;
      Global_Min_Element : Min_Element_Record := (Value => Integer'Last, Index => 0);
   end Part_Manager;

   protected body Part_Manager is
      procedure Set_Part_Min_Element(Min_Element : in Min_Element_Record) is
      begin
         if Min_Element.Value < Global_Min_Element.Value then
            Global_Min_Element := Min_Element;
         end if;
         Tasks_Count := Tasks_Count + 1;
      end Set_Part_Min_Element;

      entry Get_Min_Element(Min_Element : out Min_Element_Record) when Tasks_Count = Thread_Num is
      begin
         Min_Element := Global_Min_Element;
      end Get_Min_Element;
   end Part_Manager;

   task body Starter_Thread is
      Min_Element : Min_Element_Record;
      Start_Index, Finish_Index : Integer;
   begin
      accept Start(Start_Index, Finish_Index : in Integer) do
         Starter_Thread.Start_Index := Start_Index;
         Starter_Thread.Finish_Index := Finish_Index;
      end Start;

      Min_Element := Part_Min_Element(Start_Index  => Start_Index,
                                       Finish_Index => Finish_Index);
      Part_Manager.Set_Part_Min_Element(Min_Element);
   end Starter_Thread;

   function Parallel_Min_Element return Min_Element_Record is
      Min_Element : Min_Element_Record := (Value => Integer'Last, Index => 0);
      Thread : array(1..Thread_Num) of Starter_Thread;
      StartInd, EndInd : Integer;
   begin
      for I in 1 .. Thread_Num loop
         StartInd := I * Dim / Thread_Num;
         EndInd := (I + 1) * Dim / Thread_Num - 1;
         if I = Thread_Num then
            EndInd := Dim;
         end if;
         Thread(I).Start(StartInd, EndInd);
      end loop;
      Part_Manager.Get_Min_Element(Min_Element);
      return Min_Element;
   end Parallel_Min_Element;

begin
   Init_Arr;
   declare
      Min_Element : Min_Element_Record := Parallel_Min_Element;
   begin
      Put_Line("Minimum Element of the array: " & Min_Element.Value'Image);
      Put_Line("Index of the minimum element: " & Min_Element.Index'Image);
   end;
end thread_min_element;
