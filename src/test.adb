-- test mqtt connection

with MQTT_Clients;                 use MQTT_Clients;

with GNAT.Sockets;                 use GNAT.Sockets;
with GNAT.Sockets.MQTT;            use GNAT.Sockets.MQTT;
with GNAT.Sockets.Server;          use GNAT.Sockets.Server;
with GNAT.Sockets.Server.Handles;  use GNAT.Sockets.Server.Handles;

with Ada.Real_Time; use Ada.Real_time;
with System.IO;                    use System.IO;
with GNAT.Exception_Traces;
procedure Test is

   Server_Name    : constant String := "xxxZZ.dit.upm.es";
   Client_Name    : constant String := "b318";
   Port           : constant GNAT.Sockets.Port_Type := 1883;
   QoS            :          QoS_Level              := Exactly_Once;
   Topic_Text     : constant String := "test/temperature";
   Message_text   : constant String := "this is a test";

   Factory   : aliased Connections_Factory;
   Server    : aliased Connections_Server (Factory'Access, 0);
   Reference : Handle;

begin
   GNAT.Exception_Traces.Trace_On (GNAT.Exception_Traces.Every_Raise); 
   Set (Reference,
        new MQTT_Client (Listener             => Server'Unchecked_Access,
                         Input_Size           => 80,
                         Output_Size          => 80,
                         Max_Subscribe_Topics => 20));

   declare
      Client : MQTT_Client renames MQTT_Client (Ptr (Reference).all);
   begin
      -- connect to server
      System.IO.Put_Line("Connect to " & Server_Name & ":" & Port'Img);
      Connect (Server,
	 Client'Unchecked_Access,
         Server_Name,
         Port);
      -- wait for actual connection
      System.IO.Put_Line("Wait for connection");
 
      while not Is_Connected (Client) loop -- busy waiting
         --pragma Debug(System.IO.Put("."));
         delay until Clock + Milliseconds(100);
     end loop;
      delay until Clock+Milliseconds(1000);
      if Is_Connected(Client) then
        System.IO.Put_Line("Connected");
	
      else
	      System.IO.Put_Line("Not connected");
      end if;
   end;
end Test;
