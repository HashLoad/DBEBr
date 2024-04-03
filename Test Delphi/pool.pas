type
  TDataSetPool = class
  private
    FDataSets: array of TDataSet;
    FLock: TCriticalSection;
    FSemaphore: TSemaphore;
    FAvailablePools: TQueue<Integer>; // Fila para rastrear pools disponíveis
    FPoolSize: Integer;
  public
    constructor Create(NumPools, PoolSize: Integer);
    destructor Destroy; override;
    function GetDataSet: TDataSet;
    procedure ReturnDataSet(DataSet: TDataSet; Index: Integer);
  end;

constructor TDataSetPool.Create(NumPools, PoolSize: Integer);
var
  i: Integer;
begin
  SetLength(FDataSets, NumPools);
  FLock := TCriticalSection.Create;
  FSemaphore := TSemaphore.Create(nil, NumPools, NumPools, '', False);
  FAvailablePools := TQueue<Integer>.Create; // Inicializa a fila
  FPoolSize := PoolSize;
  for i := 0 to NumPools - 1 do
  begin
    FDataSets[i] := CreateDataSetPoolInstance(PoolSize);
    FAvailablePools.Enqueue(i); // Adiciona os índices dos pools disponíveis à fila
  end;
end;

destructor TDataSetPool.Destroy;
var
  i: Integer;
begin
  FSemaphore.Free;
  for i := 0 to Length(FDataSets) - 1 do
    FDataSets[i].Free;
  FLock.Free;
  FAvailablePools.Free; // Libera a fila
  inherited;
end;

function TDataSetPool.GetDataSet: TDataSet;
var
  Index: Integer;
begin
  FSemaphore.Acquire;
  FLock.Enter;
  try
    Index := FAvailablePools.Dequeue; // Obtém o próximo pool disponível da fila
    Result := FDataSets[Index];
  finally
    FLock.Leave;
  end;
end;

procedure TDataSetPool.ReturnDataSet(DataSet: TDataSet; Index: Integer);
begin
  FLock.Enter;
  try
    // Retorna o DataSet ao pool
    FAvailablePools.Enqueue(Index); // Adiciona o índice do pool devolvido à fila
  finally
    FLock.Leave;
    FSemaphore.Release;
  end;
end;
