
with GNAT.Sockets.Server;          use GNAT.Sockets.Server;
with Strings_Edit.Integers;        use Strings_Edit.Integers;

pragma Warnings(Off);
with System.IO;           -- for debugging
pragma Warnings(On);

package body MQTT_Clients is

   -------------------------
   -- On_Connect_Accepted --
   -------------------------

   procedure On_Connect_Accepted
     (Pier            : in out MQTT_Client;
      Session_Present : Boolean)
   is
   begin
      System.IO.Put_Line("MQTT connect accepted");
   end On_Connect_Accepted;

   -------------------------
   -- On_Connect_Rejected --
   -------------------------

   procedure On_Connect_Rejected
     (Pier     : in out MQTT_Client;
      Response : Connect_Response)
   is
   begin
	System.IO.Put_Line("Connect rejected " & Image (Response));
   end On_Connect_Rejected;

   ----------------------
   -- On_Ping_Response --
   ----------------------

   procedure On_Ping_Response (Pier : in out MQTT_Client) is
   begin
      System.IO.Put_Line("Ping response");
   end On_Ping_Response;

   ----------------
   -- On_Publish --
   ----------------

   procedure On_Publish
     (Pier      : in out MQTT_Client;
      Topic     : String;
      Message   : Stream_Element_Array;
      Packet    : Packet_Identification;
      Duplicate : Boolean;
      Retain    : Boolean)
   is
   begin
      System.IO.Put_Line("Message " & Topic & " = " & Image(Message));
      On_Publish (MQTT_Pier (Pier),
                  Topic,
                  Message,
                  Packet,
                  Duplicate,
                  Retain);
   end On_Publish;

   ----------------------------------
   -- On_Subscribe_Acknowledgement --
   ----------------------------------

   procedure On_Subscribe_Acknowledgement
     (Pier   : in out MQTT_Client;
      Packet : Packet_Identifier;
      Codes  : Return_Code_List)
   is
   begin
      for Code of Codes loop
         if Code.Success then
            System.IO.Put_Line ("Subscribed " & Image (Integer (Packet))
                           & ":" & QoS_Level'Image (Code.QoS));
         else
           System.IO.Put_Line ("Subscribe " & Image (Integer (Packet))
                           & ": failed");
         end if;
      end loop;
   end On_Subscribe_Acknowledgement;

begin
   System.IO.Set_Output(System.IO.Standard_Error);
end MQTT_Clients;
