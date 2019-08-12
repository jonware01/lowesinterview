/**
 * Interface for a room.
 */
export interface IRoom {
    Id: string;
    Identity: string;
    SamAccountName: string;
    ResourceCapacity: number;
    UserPrincipalName: string;
    Alias: string;
    DisplayName: string;
    PrimarySmtpAddress: string;
    EmailAddresses: string[];
    Floor: number;
    Street: string;
    City: string;
    State: string;
    Zip: string;
    Department: string;
    Company: string;
    HiddenFromAddressListsEnabled: boolean;
    Phone: string;
}

/**
 * Room object.
 */
export class Room implements IRoom {
    Id: string;
    Identity: string;
    SamAccountName: string;
    ResourceCapacity: number;
    UserPrincipalName: string;
    Alias: string;
    DisplayName: string;
    PrimarySmtpAddress: string;
    EmailAddresses: string[];
    Floor: number;
    Street: string;
    City: string;
    State: string;
    Zip: string;
    Department: string;
    Company: string;
    HiddenFromAddressListsEnabled: boolean;
    Phone: string;

    constructor() {}
}

/**
 * Room DTO.
 */
export class RoomDTO implements IRoom {
    // Room Interface Params
    Id: string;
    Identity: string;
    SamAccountName: string;
    ResourceCapacity: number;
    UserPrincipalName: string;
    Alias: string;
    DisplayName: string;
    PrimarySmtpAddress: string;
    EmailAddresses: string[];
    Floor: number;
    Street: string;
    City: string;
    State: string;
    Zip: string;
    Department: string;
    Company: string;
    HiddenFromAddressListsEnabled: boolean;
    Phone: string;

    // Request Params
    Name: string;
    Email: string;
    Capacity: number;
    Hide: boolean;

    constructor(room: IRoom) {
        this.Name = room.DisplayName;
        this.Email = room.PrimarySmtpAddress;
        this.Capacity = room.ResourceCapacity;
        this.Hide = room.HiddenFromAddressListsEnabled;
        this.Department = room.Department;
        this.Company = room.Company;
        this.Floor = room.Floor;
        this.Phone = room.Phone;
        this.Street = room.Street;
        this.City = room.City;
        this.State = room.State;
        this.Zip = room.Zip;
    }
}