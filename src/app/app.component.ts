import { Component, OnInit } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { IRoom, Room, RoomDTO } from './models/room';

/**
 * Main Application Component.
 */
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  protected initializing: boolean = true;
  protected uploading: boolean = false;
  protected rooms: IRoom[];

  /**
   * Constructor.
   * 
   * @param httpClient `HttpClient` to use
   */
  constructor(private httpClient: HttpClient) { }

  /**
   * On initialize, get the rooms.
   */
  public ngOnInit(): void {
    this.getRooms();
  }

  /**
   * Get rooms.
   */
  public getRooms(): void {
    this.httpClient.get<IRoom[]>("https://dcsexchange.azurewebsites.net/api/GetRooms", {
      params: new HttpParams().append("code", "JccgSq6ccljhkFd29ENtSt8MJKNRxyInJ33GrYa76EDFNWSUFzCxfA==")
    }).subscribe(rooms => {
      this.rooms = rooms;
      this.initializing = false;
    })
  }

  /**
   * Upload a file.
   * 
   * @param event File selection event
   */
  public uploadFile(event: any): void {
    this.uploading = true;

    // If file is defined, process it
    let file = event.srcElement.files[0];
    if(file) {
      // Use the FileReader API
      var reader = new FileReader();
      reader.onload = () => {
        this.readFile(reader.result.toString());
      }
      reader.readAsText(file);
    }
    else {
      this.uploading = false;
    }
  }

  /**
   * Read the file.
   * 
   * @param fileData CSV File data to read
   */
  private readFile(fileData: string): void {
    let header: string[];
    let lines: string[] = fileData.split(/\r\n/);
    let rooms: IRoom[] = [];
    
    // Read the rooms
    for(let line of lines) {
      let cols: string[] = line.split(/,/);

      // Read the header
      if(!header) {
        header = cols;
        continue;
      }

      // Build the room
      let room: IRoom = new Room();
      cols.forEach((col, colIdx) => {
        room[header[colIdx]] = col;
      });

      // Add the room
      if(room.DisplayName) {
        rooms.push(new RoomDTO(room));
      }
    }

    // Post the rooms
    this.httpClient.post("https://dcsexchange.azurewebsites.net/api/AddRoom", rooms, {
      params: new HttpParams().set("code", "KvRbHdj7MEz5eriZIzqqDv8LdHm3HladWGt7TxxcstPIMC1QjzdU7w==")
    }).subscribe(() => {
      this.uploading = false;
      this.getRooms();
    })
  }
}
