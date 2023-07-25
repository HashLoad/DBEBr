unit dbebr.driver.odac.transaction;

interface

uses
  DB,
  System.Classes,
  System.Variants,
  System.SysUtils,
  dbebr.factory.connection,
  System.Generics.Collections,
  dbebr.driver.connection,
  dbebr.factory.interfaces,
  Ora;

type
  TDriverODACTransaction = class(TDriverTransaction)
  protected
    FConnection: TOraSession;
  public
    constructor Create(AConnection: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure Rollback; override;
    function InTransaction: Boolean; override;
  end;

implementation

{ TDriverODACTransaction }

constructor TDriverODACTransaction.Create(AConnection: TComponent);
begin
  FConnection := AConnection as TOraSession;
end;

destructor TDriverODACTransaction.Destroy;
begin
  FConnection := nil;
  inherited;
end;

function TDriverODACTransaction.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

procedure TDriverODACTransaction.StartTransaction;
begin
  inherited;
  FConnection.StartTransaction;
end;

procedure TDriverODACTransaction.Commit;
begin
  inherited;
  FConnection.Commit;
end;

procedure TDriverODACTransaction.Rollback;
begin
  inherited;
  FConnection.Rollback;
end;

end.
