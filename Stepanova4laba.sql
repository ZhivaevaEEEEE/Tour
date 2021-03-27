
CREATE TABLE City
( 
	ID                   char(18)  NOT NULL ,
	TitleCity            varchar(20)  NULL ,
	ID_Country           char(18)  NOT NULL 
)
go



ALTER TABLE City
	ADD CONSTRAINT XPKCity PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Country
( 
	ID                   char(18)  NOT NULL ,
	TitleCountry         varchar(20)  NULL ,
	Embassy              integer  NULL 
)
go



ALTER TABLE Country
	ADD CONSTRAINT XPKCountry PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Discount
( 
	ID                   char(18)  NOT NULL ,
	SizeDiscount         integer  NULL ,
	TitleDiscount        varchar(20)  NULL ,
	DateStart            datetime  NULL ,
	DateEnd              datetime  NULL 
)
go



ALTER TABLE Discount
	ADD CONSTRAINT XPKDiscount PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Hotel
( 
	ID                   char(18)  NOT NULL ,
	TitleHotel           varchar(20)  NULL ,
	CountStars           integer  NULL ,
	PlacementType        varchar(20)  NULL ,
	PriceOneNight        integer  NULL ,
	ID_City              char(18)  NOT NULL 
)
go



ALTER TABLE Hotel
	ADD CONSTRAINT XPKHotel PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE PriceList
( 
	ID                   char(18)  NOT NULL ,
	TitlePriceList       varchar(20)  NULL ,
	FromDate             datetime  NULL ,
	ToDate               datetime  NULL ,
	Price                integer  NULL 
)
go



ALTER TABLE PriceList
	ADD CONSTRAINT XPKPriceList PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Tour
( 
	ID                   char(18)  NOT NULL ,
	DepartureFlight      varchar(20)  NULL ,
	ArrivalFlight        varchar(20)  NULL ,
	FoodType             varchar(20)  NULL ,
	ID_PriceList         char(18)  NOT NULL ,
	ID_Discount          char(18)  NOT NULL ,
	ID_Hotel             char(18)  NOT NULL 
)
go



ALTER TABLE Tour
	ADD CONSTRAINT XPKTour PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Tourist
( 
	Surname              varchar(20)  NULL ,
	Name                 varchar(20)  NULL ,
	Pathronymic          varchar(20)  NULL ,
	BirthDate            datetime  NULL ,
	Adress               varchar(20)  NULL ,
	Telephone            varchar(20)  NULL ,
	ID                   integer  NOT NULL 
)
go



ALTER TABLE Tourist
	ADD CONSTRAINT XPKTourist PRIMARY KEY  CLUSTERED (ID ASC)
go



CREATE TABLE Trip
( 
	SaleDate             datetime  NULL ,
	Group                integer  NULL ,
	Insurance            varchar(20)  NULL ,
	ID_tourist           integer  NOT NULL ,
	ID_tour              char(18)  NOT NULL ,
	ID                   char(18)  NOT NULL 
)
go



ALTER TABLE Trip
	ADD CONSTRAINT XPKTrip PRIMARY KEY  CLUSTERED (ID ASC)
go




ALTER TABLE City
	ADD CONSTRAINT R_25 FOREIGN KEY (ID_Country) REFERENCES Country(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Hotel
	ADD CONSTRAINT R_24 FOREIGN KEY (ID_City) REFERENCES City(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Tour
	ADD CONSTRAINT R_20 FOREIGN KEY (ID_PriceList) REFERENCES PriceList(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Tour
	ADD CONSTRAINT R_22 FOREIGN KEY (ID_Discount) REFERENCES Discount(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Tour
	ADD CONSTRAINT R_23 FOREIGN KEY (ID_Hotel) REFERENCES Hotel(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Trip
	ADD CONSTRAINT R_9 FOREIGN KEY (ID_tourist) REFERENCES Tourist(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




ALTER TABLE Trip
	ADD CONSTRAINT R_12 FOREIGN KEY (ID_tour) REFERENCES Tour(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go




CREATE PROCEDURE get_trip_by_date @dt datetime
 WITH 
 EXECUTE AS OWNER 
 AS 
 SELECT SaleDate, Group, Insurance
 FROM Trip
 WHERE SaleDate = @dt
 RETURN
Go

go




CREATE TRIGGER tD_City ON City FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on City */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* City  Hotel on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0001f1aa", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="Hotel"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_24", FK_COLUMNS="ID_City" */
    IF EXISTS (
      SELECT * FROM deleted,Hotel
      WHERE
        /*  %JoinFKPK(Hotel,deleted," = "," AND") */
        Hotel.ID_City = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete City because Hotel exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* Country  City on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Country"
    CHILD_OWNER="", CHILD_TABLE="City"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_25", FK_COLUMNS="ID_Country" */
    IF EXISTS (SELECT * FROM deleted,Country
      WHERE
        /* %JoinFKPK(deleted,Country," = "," AND") */
        deleted.ID_Country = Country.ID AND
        NOT EXISTS (
          SELECT * FROM City
          WHERE
            /* %JoinFKPK(City,Country," = "," AND") */
            City.ID_Country = Country.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last City because Country exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_City ON City FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on City */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* City  Hotel on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="00022795", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="Hotel"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_24", FK_COLUMNS="ID_City" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Hotel
      WHERE
        /*  %JoinFKPK(Hotel,deleted," = "," AND") */
        Hotel.ID_City = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update City because Hotel exists.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* Country  City on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Country"
    CHILD_OWNER="", CHILD_TABLE="City"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_25", FK_COLUMNS="ID_Country" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_Country)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Country
        WHERE
          /* %JoinFKPK(inserted,Country) */
          inserted.ID_Country = Country.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update City because Country does not exist.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Country ON Country FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Country */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Country  City on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0000e166", PARENT_OWNER="", PARENT_TABLE="Country"
    CHILD_OWNER="", CHILD_TABLE="City"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_25", FK_COLUMNS="ID_Country" */
    IF EXISTS (
      SELECT * FROM deleted,City
      WHERE
        /*  %JoinFKPK(City,deleted," = "," AND") */
        City.ID_Country = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete Country because City exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Country ON Country FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Country */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Country  City on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0000fafe", PARENT_OWNER="", PARENT_TABLE="Country"
    CHILD_OWNER="", CHILD_TABLE="City"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_25", FK_COLUMNS="ID_Country" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,City
      WHERE
        /*  %JoinFKPK(City,deleted," = "," AND") */
        City.ID_Country = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Country because City exists.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Discount ON Discount FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Discount */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Discount  Tour on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0000de23", PARENT_OWNER="", PARENT_TABLE="Discount"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="ID_Discount" */
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_Discount = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete Discount because Tour exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Discount ON Discount FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Discount */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Discount  Tour on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0000f4a8", PARENT_OWNER="", PARENT_TABLE="Discount"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="ID_Discount" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_Discount = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Discount because Tour exists.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Hotel ON Hotel FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Hotel */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Hotel  Tour on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0001de2b", PARENT_OWNER="", PARENT_TABLE="Hotel"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="ID_Hotel" */
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_Hotel = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete Hotel because Tour exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* City  Hotel on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="Hotel"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_24", FK_COLUMNS="ID_City" */
    IF EXISTS (SELECT * FROM deleted,City
      WHERE
        /* %JoinFKPK(deleted,City," = "," AND") */
        deleted.ID_City = City.ID AND
        NOT EXISTS (
          SELECT * FROM Hotel
          WHERE
            /* %JoinFKPK(Hotel,City," = "," AND") */
            Hotel.ID_City = City.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Hotel because City exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Hotel ON Hotel FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Hotel */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Hotel  Tour on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="00022a9c", PARENT_OWNER="", PARENT_TABLE="Hotel"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="ID_Hotel" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_Hotel = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Hotel because Tour exists.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* City  Hotel on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="Hotel"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_24", FK_COLUMNS="ID_City" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_City)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,City
        WHERE
          /* %JoinFKPK(inserted,City) */
          inserted.ID_City = City.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Hotel because City does not exist.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_PriceList ON PriceList FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on PriceList */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* PriceList  Tour on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0000dbc3", PARENT_OWNER="", PARENT_TABLE="PriceList"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_20", FK_COLUMNS="ID_PriceList" */
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_PriceList = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete PriceList because Tour exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_PriceList ON PriceList FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on PriceList */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* PriceList  Tour on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0000f192", PARENT_OWNER="", PARENT_TABLE="PriceList"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_20", FK_COLUMNS="ID_PriceList" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Tour
      WHERE
        /*  %JoinFKPK(Tour,deleted," = "," AND") */
        Tour.ID_PriceList = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update PriceList because Tour exists.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Tour ON Tour FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Tour */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Tour  Trip on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0004151b", PARENT_OWNER="", PARENT_TABLE="Tour"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="ID_tour" */
    IF EXISTS (
      SELECT * FROM deleted,Trip
      WHERE
        /*  %JoinFKPK(Trip,deleted," = "," AND") */
        Trip.ID_tour = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete Tour because Trip exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* PriceList  Tour on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="PriceList"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_20", FK_COLUMNS="ID_PriceList" */
    IF EXISTS (SELECT * FROM deleted,PriceList
      WHERE
        /* %JoinFKPK(deleted,PriceList," = "," AND") */
        deleted.ID_PriceList = PriceList.ID AND
        NOT EXISTS (
          SELECT * FROM Tour
          WHERE
            /* %JoinFKPK(Tour,PriceList," = "," AND") */
            Tour.ID_PriceList = PriceList.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Tour because PriceList exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* Discount  Tour on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Discount"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="ID_Discount" */
    IF EXISTS (SELECT * FROM deleted,Discount
      WHERE
        /* %JoinFKPK(deleted,Discount," = "," AND") */
        deleted.ID_Discount = Discount.ID AND
        NOT EXISTS (
          SELECT * FROM Tour
          WHERE
            /* %JoinFKPK(Tour,Discount," = "," AND") */
            Tour.ID_Discount = Discount.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Tour because Discount exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* Hotel  Tour on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Hotel"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="ID_Hotel" */
    IF EXISTS (SELECT * FROM deleted,Hotel
      WHERE
        /* %JoinFKPK(deleted,Hotel," = "," AND") */
        deleted.ID_Hotel = Hotel.ID AND
        NOT EXISTS (
          SELECT * FROM Tour
          WHERE
            /* %JoinFKPK(Tour,Hotel," = "," AND") */
            Tour.ID_Hotel = Hotel.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Tour because Hotel exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Tour ON Tour FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Tour */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Tour  Trip on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0004ad72", PARENT_OWNER="", PARENT_TABLE="Tour"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="ID_tour" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Trip
      WHERE
        /*  %JoinFKPK(Trip,deleted," = "," AND") */
        Trip.ID_tour = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Tour because Trip exists.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* PriceList  Tour on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="PriceList"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_20", FK_COLUMNS="ID_PriceList" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_PriceList)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,PriceList
        WHERE
          /* %JoinFKPK(inserted,PriceList) */
          inserted.ID_PriceList = PriceList.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Tour because PriceList does not exist.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* Discount  Tour on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Discount"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="ID_Discount" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_Discount)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Discount
        WHERE
          /* %JoinFKPK(inserted,Discount) */
          inserted.ID_Discount = Discount.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Tour because Discount does not exist.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* Hotel  Tour on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Hotel"
    CHILD_OWNER="", CHILD_TABLE="Tour"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="ID_Hotel" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_Hotel)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Hotel
        WHERE
          /* %JoinFKPK(inserted,Hotel) */
          inserted.ID_Hotel = Hotel.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Tour because Hotel does not exist.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Tourist ON Tourist FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Tourist */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Tourist  Trip on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0000e2cd", PARENT_OWNER="", PARENT_TABLE="Tourist"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_9", FK_COLUMNS="ID_tourist" */
    IF EXISTS (
      SELECT * FROM deleted,Trip
      WHERE
        /*  %JoinFKPK(Trip,deleted," = "," AND") */
        Trip.ID_tourist = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete Tourist because Trip exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Tourist ON Tourist FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Tourist */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID integer,
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Tourist  Trip on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0000fd4a", PARENT_OWNER="", PARENT_TABLE="Tourist"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_9", FK_COLUMNS="ID_tourist" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(ID)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Trip
      WHERE
        /*  %JoinFKPK(Trip,deleted," = "," AND") */
        Trip.ID_tourist = deleted.ID
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Tourist because Trip exists.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go




CREATE TRIGGER tD_Trip ON Trip FOR DELETE AS
/* ERwin Builtin Trigger */
/* DELETE trigger on Trip */
BEGIN
  DECLARE  @errno   int,
           @errmsg  varchar(255)
    /* ERwin Builtin Trigger */
    /* Tourist  Trip on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00021909", PARENT_OWNER="", PARENT_TABLE="Tourist"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_9", FK_COLUMNS="ID_tourist" */
    IF EXISTS (SELECT * FROM deleted,Tourist
      WHERE
        /* %JoinFKPK(deleted,Tourist," = "," AND") */
        deleted.ID_tourist = Tourist.ID AND
        NOT EXISTS (
          SELECT * FROM Trip
          WHERE
            /* %JoinFKPK(Trip,Tourist," = "," AND") */
            Trip.ID_tourist = Tourist.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Trip because Tourist exists.'
      GOTO ERROR
    END

    /* ERwin Builtin Trigger */
    /* Tour  Trip on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Tour"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="ID_tour" */
    IF EXISTS (SELECT * FROM deleted,Tour
      WHERE
        /* %JoinFKPK(deleted,Tour," = "," AND") */
        deleted.ID_tour = Tour.ID AND
        NOT EXISTS (
          SELECT * FROM Trip
          WHERE
            /* %JoinFKPK(Trip,Tour," = "," AND") */
            Trip.ID_tour = Tour.ID
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Trip because Tour exists.'
      GOTO ERROR
    END


    /* ERwin Builtin Trigger */
    RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


CREATE TRIGGER tU_Trip ON Trip FOR UPDATE AS
/* ERwin Builtin Trigger */
/* UPDATE trigger on Trip */
BEGIN
  DECLARE  @NUMROWS int,
           @nullcnt int,
           @validcnt int,
           @insID char(18),
           @errno   int,
           @errmsg  varchar(255)

  SELECT @NUMROWS = @@rowcount
  /* ERwin Builtin Trigger */
  /* Tourist  Trip on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00027789", PARENT_OWNER="", PARENT_TABLE="Tourist"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_9", FK_COLUMNS="ID_tourist" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_tourist)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Tourist
        WHERE
          /* %JoinFKPK(inserted,Tourist) */
          inserted.ID_tourist = Tourist.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Trip because Tourist does not exist.'
      GOTO ERROR
    END
  END

  /* ERwin Builtin Trigger */
  /* Tour  Trip on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Tour"
    CHILD_OWNER="", CHILD_TABLE="Trip"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="ID_tour" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(ID_tour)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Tour
        WHERE
          /* %JoinFKPK(inserted,Tour) */
          inserted.ID_tour = Tour.ID
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @NUMROWS
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Trip because Tour does not exist.'
      GOTO ERROR
    END
  END


  /* ERwin Builtin Trigger */
  RETURN
ERROR:
    raiserror @errno @errmsg
    rollback transaction
END

go


