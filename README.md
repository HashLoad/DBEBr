# DBEBr Framework for Delphi/Lazaruz

DATABASE ENGINE é um framework opensource que provê desacoplamento de conexão através de uma interface orientada a objeto, deixando seu sistema totalmente desacoplado de um único Engine de conexão, proporcionando de forma fácil e simples a troca para usar qualquer Engine disponível no mercado, seja ele FireDAC, DBExpress, Zeos entre outros. Fique livre de engine de conexão, sua aplicação só irá reconhecer o DBEBr.

<p align="center">
  <a href="https://www.isaquepinheiro.com.br">
    <img src="https://github.com/HashLoad/DBEBr/blob/master/Images/dbebr_framework.png" width="200" height="200">
  </a>
</p>

## 🏛 Delphi Versions
Embarcadero Delphi XE e superior.

## ⚙️ Instalação
Instalação usando o [`boss install`]
```sh
boss install "https://github.com/HashLoad/dbebr"
```

## ⚡️ Como usar
```Delphi
const
  cSQLSELECT = 'SELECT CLIENT_NAME FROM CLIENT WHERE CLIENT_ID = %s';
  cSQLUPDATE = 'UPDATE CLIENT SET CLIENT_NAME = %s WHERE CLIENT_ID = %s';
  cSQLUPDATEPARAM = 'UPDATE CLIENT SET CLIENT_NAME = :CLIENT_NAME WHERE CLIENT_ID = :CLIENT_ID';
  cDESCRIPTION = 'Description Randon=';

  ...
  
  TDriverConnection = class(TObject)
  strict private
    FConnection: TFDConnection;
    FDBConnection: IDBConnection;
    FDBQuery: IDBQuery;
    FDBResultSet: IDBResultSet;
    
    ...
    
procedure TDriverConnection.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FConnection.Params.DriverID := 'SQLite';
  FConnection.Params.Database := '.\database.db3';
  FConnection.LoginPrompt := False;
  FConnection.TxOptions.Isolation := xiReadCommitted;
  FConnection.TxOptions.AutoCommit := False;

  FDBConnection := TFactoryFireDAC.Create(FConnection, dnSQLite);
end;
```


```Delphi
procedure TDriverConnection.ExecuteDirect;
var
  LValue: String;
  LRandon: String;
begin
  LRandon := IntToStr( Random(9999) );

  FDBConnection.ExecuteDirect( Format(cSQLUPDATE, [QuotedStr(cDESCRIPTION + LRandon), '1']) );

  FDBQuery := FDBConnection.CreateQuery;
  FDBQuery.CommandText := Format(cSQLSELECT, ['1']);
  LValue := FDBQuery.ExecuteQuery.FieldByName('CLIENT_NAME').AsString;
end;
```

```Delphi
procedure TDriverConnection.ExecuteDirectParams;
var
  LParams: TParams;
  LRandon: String;
  LValue: String;
begin
  LRandon := IntToStr( Random(9999) );

  LParams := TParams.Create(nil);
  try
    with LParams.Add as TParam do
    begin
      Name := 'CLIENT_NAME';
      DataType := ftString;
      Value := cDESCRIPTION + LRandon;
      ParamType := ptInput;
    end;
    with LParams.Add as TParam do
    begin
      Name := 'CLIENT_ID';
      DataType := ftInteger;
      Value := 1;
      ParamType := ptInput;
    end;
    FDBConnection.ExecuteDirect(cSQLUPDATEPARAM, LParams);

    FDBResultSet := FDBConnection.CreateResultSet(Format(cSQLSELECT, ['1']));
    LValue := FDBResultSet.FieldByName('CLIENT_NAME').AsString;
  finally
    LParams.Free;
  end;
end;
```

```Delphi
procedure TDriverConnection.Transaction;
begin
  FDBConnection.Connect;
  try
    FDBConnection.StartTransaction;
    try
      
      // seu código aqui
      
      FDBConnection.Commit;
    except
      FDBConnection.Rollback;
    end;
  finally
    FDBConnection.Disconnect;
  end;  
end;
```

```Delphi
procedure TDriverConnection.CreateQuery;
var
  LValue: String;
  LRandon: String;
begin
  LRandon := IntToStr( Random(9999) );

  FDBQuery := FDBConnection.CreateQuery;
  FDBQuery.CommandText := Format(cSQLUPDATE, [QuotedStr(cDESCRIPTION + LRandon), '1']);
  FDBQuery.ExecuteDirect;

  FDBQuery.CommandText := Format(cSQLSELECT, ['1']);
  LValue := FDBQuery.ExecuteQuery.FieldByName('CLIENT_NAME').AsString;
end;
```

```Delphi
procedure TDriverConnection.CreateResultSet;
begin
  FDBResultSet := FDBConnection.CreateResultSet(Format(cSQLSELECT, ['1']));
  
  while FDBResultSet.eof do
  begin
     // seu código aqui
  end;
end;
```

## ✍️ License
[![License](https://img.shields.io/badge/Licence-LGPL--3.0-blue.svg)](https://opensource.org/licenses/LGPL-3.0)

## ⛏️ Contribuição

Nossa equipe adoraria receber contribuições para este projeto open source. Se você tiver alguma ideia ou correção de bug, sinta-se à vontade para abrir uma issue ou enviar uma pull request.

[![Issues](https://img.shields.io/badge/Issues-channel-orange)](https://github.com/HashLoad/ormbr/issues)

Para enviar uma pull request, siga estas etapas:

1. Faça um fork do projeto
2. Crie uma nova branch (`git checkout -b minha-nova-funcionalidade`)
3. Faça suas alterações e commit (`git commit -am 'Adicionando nova funcionalidade'`)
4. Faça push da branch (`git push origin minha-nova-funcionalidade`)
5. Abra uma pull request

## 📬 Contato
[![Telegram](https://img.shields.io/badge/Telegram-channel-blue)](https://t.me/hashload)

## 💲 Doação
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)
