-- Password_Gen: a password-generator program
-- Copyright (C) 2021 by PragmAda Software Engineering.  All rights reserved.
-- **************************************************************************
--
-- User Interface
--
-- V3.0  2021 Jul 15     Ada_GUI version
-- V2.1  2019 May 01     Task to update length display while being changed
-- V2.0  2018 Aug 01     Singleton version
-- V1.2  2017 Nov 15     Move password-generation logic into a package
-- V1.1  2016 Jun 01     Correct handling when no digit
-- V1.0  2016 Jan 15     Initial version
--
with Ada.Exceptions;
with Ada.Real_Time;
with Ada.Text_IO;
with Ada.Strings.Unbounded;

with Ada_GUI;

with Password_Generation;

package body Password_Gen.UI is
   Domain       : Ada_GUI.Widget_ID;
   Master       : Ada_GUI.Widget_ID;
   Length       : Ada_GUI.Widget_ID;
   Symbol_Label : Ada_GUI.Widget_ID;
   Symbol       : Ada_GUI.Widget_ID;
   Hash_Symbol  : Ada_GUI.Widget_ID;
   Result       : Ada_GUI.Widget_ID;
   Generate     : Ada_GUI.Widget_ID;
   Quit         : Ada_GUI.Widget_ID;
   Event        : Ada_GUI.Next_Result_Info;

   use type Ada.Strings.Unbounded.Unbounded_String;
   use type Ada_GUI.Event_Kind_ID;
   use type Ada_GUI.Widget_ID;
begin -- Password_Gen.UI
   Ada_GUI.Set_Up (Grid => (1 => (1 => (Kind => Ada_GUI.Area, Alignment => Ada_GUI.Right),
                                  2 => (Kind => Ada_GUI.Area, Alignment => Ada_GUI.Left) ) ),
                   Title => "Password Generator");

   Domain := Ada_GUI.New_Text_Box (Text => "", Label => "Domain:", Placeholder => "example.com, example.fr, example.co.uk");
   Master := Ada_GUI.New_Password_Box (Break_Before => True, Label => "Master Password:");
   Length := Ada_GUI.New_Text_Box (Text => "14", Break_Before => True, Label => "Password Length (8-20):", Width => 2);
   Length.Set_Text_Alignment (Alignment => Ada_GUI.Right);
   Symbol_Label := Ada_GUI.New_Background_Text (Text => "Symbol:", Break_Before => True);
   Symbol := Ada_GUI.New_Selection_List;
   Symbol.Insert (Text => Password_Generation.No_Symbol);
   Symbol.Insert (Text => Password_Generation.Auto_Symbol);

   All_Symbols : for I in Password_Generation.Symbol_Set'Range loop
      Symbol.Insert (Text => Password_Generation.Symbol_Set (I) & "");
   end loop All_Symbols;

   Symbol.Set_Selected (Index => 2); -- Auto
   Hash_Symbol := Ada_GUI.New_Check_Box (Label => "Include Symbol in hash", Active => True);
   Result := Ada_GUI.New_Text_Box (Text => "", Break_Before => True);
   Result.Set_Text_Font_Kind (Kind => Ada_GUI.Monospaced);
   Generate := Ada_GUI.New_Button (Text => "Generate");
   Quit := Ada_GUI.New_Button (Text => "Quit", Break_Before => True);

   All_Events : loop
      Event := Ada_GUI.Next_Event (Timeout => 1.0);

      if not Event.Timed_Out then
         exit All_Events when Event.Event.Kind = Ada_GUI.Window_Closed;

         if Event.Event.Kind = Ada_GUI.Left_Click then
            exit All_Events when Event.Event.ID = Quit;

            if Event.Event.ID = Generate then
               Generation : begin
                  Result.Set_Text (Text => Password_Generation.Generate (Domain.Text,
                                                                         Master.Text,
                                                                         Positive'Value (Length.Text),
                                                                         Symbol.Text,
                                                                         Hash_Symbol.Active) );
               exception -- Generation
               when others => -- Invalid Length
                  Length.Set_Text (Text => "14");
                  Result.Set_Text (Text => "");
               end Generation;
            end if;
         end if;
      end if;
   end loop All_Events;

   Ada_GUI.End_GUI;
exception -- Password_Gen.UI
when E : others =>
   Ada.Text_IO.Put_Line (Item => Ada.Exceptions.Exception_Information (E) );
end Password_Gen.UI;
--
-- SPDX-License-Identifier: GPL-2.0-only
-- See https://spdx.org/licenses/
-- If you find this software useful, please let me know, either through
-- github.com/jrcarter or directly to pragmada@pragmada.x10hosting.com
