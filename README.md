# utilitarios

**#_INSERT.SQL**
Essa função recebe o nome da table como parâmetro(char), e monta um insert com os nomes das colunas, em posição vertical, valores defaults para os campos:
- Integer/Numeric: 0 / 0.0
- Char/Text: ''
- Date: current_date
- Timestamp: now()
- Se a coluna tiver SEQUENCE, o valor default será o nextval.
- Se a coluna for NOT NULL, seu nome será marcado com dois asteriscos **.

**EXEMPLO:**
```sql
SELECT _insert('teste');

INSERT INTO teste(
id,hora,dia,string,numero,valor) VALUES(
SELECT nextval('teste_id_seq'::regclass);  --id**
,now()  --hora**
,current_date  --dia**
,''  --string
,0  --numero
,0.0  --valor
);
```
