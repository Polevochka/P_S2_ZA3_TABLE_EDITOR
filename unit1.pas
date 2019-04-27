unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;



implementation

{$R *.lfm}

// Наши собственные типы данных, используемые в приложении
Type

  // тип для отдельно взятого студена
  Stud = Record
    No       : integer;     // Номер (его ID)
    Name     : string[12];  // Имя
    Gr       : string[8];   // Группа
    o1,o2,o3 : integer;     // Оценки
  end;

// Глобальные переменные
var sf: string; // Спецификация файла - его полное имя


//Собственные процедуры и функции

{Параметры таблицы по умолчанию}
procedure TabForFile;
var i: integer;
begin
  // Используем менеджер контекста для сокращения,
  // чтобы слишком часто не писать длинную строчку для доступа к атрибуту
  // По типу Form1.Stringgrid1.attr, как бы считаем что мы внутри StringGrid1
  // И Можем не указывать полное имя, чтобы поменять что-то внутри
  with Form1.StringGrid1 do
  begin

    ColCount := 6;  // Число столбцов  для (1)номера, (2)имени, (3)групы и (4-6)оценок одного студента
    RowCount := 50; // Количество строк

    // Устанавливаем ширину отдельных ячеек, т.к. для, например, имени и оценки нужно разное число полей
    // Столбцы (как почти и всё) нумеруются с нуля!!!
    ColWidths[0] := 20;  // на Номер студента 20 пикселей
    ColWidths[1] := 120; // на Фамилию - 120
    ColWidths[2] := 80;  // Группа
    ColWidths[3] := 40;  // Маленкое поле для Оценки 1
    ColWidths[4] := 40;  // Оц 2
    ColWidths[5] := 40;  // Оц 3

    // Заполняем заголовок нашей таблицы
    Cells[0,0] := '№';
    Cells[1,0] := 'Фамилия';
    Cells[2,0] := 'Группа';
    Cells[3,0] := 'Оц 1';
    Cells[4,0] := 'Оц 2';
    Cells[5,0] := 'Оц 3';

    // Теперь устанавливаем ширину всей таблицы
    width := 25; // дополнительные 25 пикселей на полосу прокрути и прочее
    for i:=0 to ColCount-1 do
      width:= width + ColWidths[i]; // Прибавляем ширину i-го столбца к общей ширине таблицы

  end;
end;

{Процедура очищения таблицы (без заголовка)}
// StringGrid1.Clean - очищает всю таблицу
// Процедура НЕОБЯЗАТЕЛЬНАЯ, можно спокойно писать каждый раз TabForFile -
// Устанавливать параметры таблицы по умолчанию
Procedure ClearTab;
var i, j: integer;
begin
  with Form1.StringGrid1 do
    // Перебираем все строки кроме заголока(i=0)
    for i:= 1 to RowCount -1 do
      // Не имеет смысла очищать строку если она пустая
      if (CellS[0,i] <>'') then
        // Перебираем все столбцы
        for j:=0 to ColCount-1 do
          Cells[j,i] :=''; // 'обнуляем'нужные ячейки
end;

{Сохранить данные о студентах в файл}
procedure SaveToFileOfStud;
var f: file of stud;
    s: stud; // Переменная для СЧИТЫВАНИЯ ИЗ StringGrid1 одного студента и записи его в файл
    i: integer;
begin
  // Здесь считаем что sf - не пустая строка, то есть имя файла уже задано

  // Стандартные действия по подготовке к ЗАПИСИ в файл
  AssignFile(f, sf);
  Rewrite(f);

  with Form1.StringGrid1 do
    // Перебираем строки
    // Причом начинаем с 1, тк на 0 месте строка ЗАГОЛОВКА
    for i:=1 to RowCount -1 do
      // Перебираем НЕ ПУСТЫЕ строки
      if CellS[0,i] <>'' then
      begin
        // Записываем в s нужные поля, кто он, где учится, как учится и тп
        s.No   := StrToInt(Cells[0,i]); // Заполняем Номер студента
        s.Name := Cells[1,i];           // Получаем  Фамилию студента
        s.Gr   := Cells[2,i];           // Группа студента
        // Оценки
        s.o1   := StrToInt(Cells[3,i]);
        s.o2   := StrToInt(Cells[4,i]);
        s.o3   := StrToInt(Cells[5,i]);

        // Полученного студента записываем в файл
        write(f,s);
      end;

// в самом конце закрываем файл
CloseFile(f);
end;

{Загрузить данные о студентах в таблицу из файла}
procedure LoadFromFileOfStud;
var f: file of Stud;
    s: stud; // Переменная для ЗАПИСИ В StringGrid1 одного студента и считывания его из файла
    i: integer;
begin

  // Подготавливаем файл к ЧТЕНИЮ
  AssignFile(f, sf);
  Reset(f);

  with Form1.StringGrid1 do
  // Опять же начинаем с еденицы, чтобы не задеть заголовок
  for i:=1 to filesize(f) do
  begin

    // Считываем одного студента
    read(f,s);

    // И записываем данные о нём в таблицу
    Cells[0,i]:= IntToStr(s.No);  // Его Номер
    Cells[1,i]:= s.Name;          // Фамилия
    Cells[2,i]:= s.Gr;            // Группа
    Cells[3,i]:= IntToStr(s.o1);
    Cells[4,i]:= IntToStr(s.o2);   {И оценки}
    Cells[5,i]:= IntToStr(s.o3);
  end;

// и в самом конце закрываем файл
closefile(f);
end;


// Процедуры-Обработчики на форме
{ TForm1 }

{Особые действия при открытии программы}
procedure TForm1.FormCreate(Sender: TObject);
begin
  TabForFile; // Устанавливаем параметры таблицы по умолчанию
  // Добавляем оциию редактирования содержимого таблицы
  StringGrid1.Options:=StringGrid1.Options + [goEditing];
  StringGrid1.FixedCols:=0; //Чтобы можно было редактировать номера
  StringGrid1.Modified := False;
  sf := '';   // Никакого файла мы ещё не открывали

  // Каталоги для сохраненияи открытия по умочанию (Папка проекта)
  OpenDialog1.InitialDir:='';
  SaveDialog1.InitialDir:='';
end;

{Создать}
procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  ClearTab;  // Очищаем таблицу своей процедурой, что равносильно изменению Таблицы
  StringGrid1.Modified:= False; // Таблица не была изменена
  sf:='';     // А у файла нет ещё имени
  Form1.Caption:= 'Form1';
end;

{Открыть}
procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  // диалог сохранинея файла
  if StringGrid1.Modified then
    case MessageDlg('Текст был изменён' + #13 + 'Сохранить его?',
                    mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes   : MenuItem5Click(self); // Сохраняем файл
      mrNo    : ;                     // Ничего не делаем
      mrCancel: Exit;                 // выходим из процедуры {Открыть}
    end;

  // Если дилог открытия файла завершился нормально,
  // То есть его не закрыли и не нажали cancel
  // То есть юзер выбрал нужный ему файл и нажал ОК
  if openDialog1.Execute then
  begin
    sf:=OpenDialog1.FileName;     // Извлекаем имя файла из этого диалога
    LoadFromFileOfStud;           // Выводим его в StringGrid1
    StringGrid1.Modified:=False;  // Что равносильно его изменению, но мы же не изменяли файл
    Form1.Caption:='Form1 ' + sf; // В заголовок окна выводим имя файла
  end;
end;

{Закрыть}
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  // Стандартных диалог сохранения файла
  // Если таблица была изменена
  if StringGrid1.Modified then
    // Стандартное окно Сообщения
    case MessageDlg('Данные о студентах были изменены' + #13 + 'Сохранить их?',
                                  mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes: MenuItem5Click(self); // Сохраняем файл
      mrNo:;                       // Ничего не делаем
      mrCancel: Exit; // Выходим из окна сообщения, и возвращаемся к редактированию таблицы(действия ниже выполняться не будут)
    end;

  // Если мы НЕ вишли через 'Cancel', то совершаем стандартные действия
  ClearTab;  // Очищаем таблицу процедурой собственного производства  и тд
  StringGrid1.Modified:= False;
  sf:='';
  Form1.Caption:= 'Form1';
end;

{Сохранить}
procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  // Исли имя файла не задано то вызываем Окно {сохранить как}
  if sf = '' then MenuItem6Click(self)
  else  // Иначе, то есть имя файла уже установлено
  begin
    SaveToFileOfStud; // Сразу сохраняем его на диск
    StringGrid1.Modified:= False;  // Содержание устанавливаем не изменённым, тк сохранили всё на диск
  end;
end;

{Сохранить как}
procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  // Если диалог сохранения прошёл хорошо
  if SaveDialog1.Execute then
  begin
    sf:= SaveDialog1.FileName; // Извлекаем имя файла
    SaveToFileOfStud;          // Используя нашу процедуру, сохраняем содержимое таблицы в файл

    StringGrid1.Modified := False; // Содержимое в таблице соответсвует файлу на диске
    Form1.Caption:= 'Form1 ' + sf; // Устанавливаем заголовок приложения с именем файла
  end;
end;

{Выход}
procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  // Сообщение: Сохранить ли именённый файл
  if StringGrid1.Modified then
    case MessageDlg('Таблица была изменена' + #13 + 'Сохранить её?',
                       mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes   : MenuItem5Click(self);  // Сохраняем изменения в файл
      mrNo    : ;                      // Ничего не делаем
      mrCancel: Exit;                  // Возвращаемся к редактирования таблицы
    end;

  // Закрываем приложение
  Close;
end;


// Обработка

{Получить одного студента из i-ой строки таблицы}
// var s - так как изменяем поля студента
procedure GetStud(i: integer; var s: Stud);
begin
  with Form1.StringGrid1 do
  begin
    // Записываем в s нужные поля, кто он, где учится, как учится и тп
    s.No   := StrToInt(Cells[0,i]); // Заполняем Номер студента
    s.Name := Cells[1,i];           // Получаем  Фамилию студента
    s.Gr   := Cells[2,i];           // Группа студента
    // Оценки
    s.o1   := StrToInt(Cells[3,i]);
    s.o2   := StrToInt(Cells[4,i]);
    s.o3   := StrToInt(Cells[5,i]);
  end;

end;

{Записать одного студенто в i-ую строку таблицы}
procedure WriteStud(i: integer; s: Stud);
begin
  with Form1.StringGrid1 do
  begin
    // И записываем данные о студенте в таблицу
    Cells[0,i]:= IntToStr(s.No);  // Его Номер
    Cells[1,i]:= s.Name;          // Фамилия
    Cells[2,i]:= s.Gr;            // Группа
    Cells[3,i]:= IntToStr(s.o1);
    Cells[4,i]:= IntToStr(s.o2);   {И оценки}
    Cells[5,i]:= IntToStr(s.o3);
  end;
end;

{Сортировка}
procedure TForm1.MenuItem9Click(Sender: TObject);
var i, j: integer;
    i_min: integer; // индекс 'минимального' студента
    n: integer; // число НЕПУСТЫХ строк в таблице
    s, s_min: Stud; // студенты которых будем менять местами
begin
  // Здесь мы считаем, что юзер уже открыл файл на редактирование(sf - не пустая)

  // У StringGrid есть замечательное свойство Rows, которое помогает обращаться
  // к строкам таблицы
  // так например написав StringGrid.Rows[1] - мы получим вторую строку таблицы
  // Причём сама строка таблицы Rows[i] - является массивом строк,
  // Так при помощи такого полезного инструмента мы можем сразу менять строки,
  // а не копировать строки по одной ячейке
  // То есть можно сразу написать
  // StringGrid1.Rows[1] := StringGrid1.Rows[2];
  // Теперь в ячейках 2-ой строки(Rows[1]) будет то же самое, что и в ячейках
  // 3-ей строки (Rows[2])
  // Строки нумеруются с 0!!!

  // Обходим Получаем сколько у нас строк с записями в таблицы
  // сколько строк - не являются пустыми
  n := 0;
  // Будем считать что если ПЕРВЫЙ столбец строки пустой - то и ВСЯ строка - ПУСТАЯ
  // Начнём со строки после заголовка (n+1)- то есть заголовок(n=0) учитываться не будет
  while( StringGrid1.Cells[0, n+1] <> '') do
    n := n + 1;

  // Получили число заполненных строк - n(Без заголовка)

  // Используем менаджер контекста, чтобы меньше писать StringGrid1
  // каждый раз обращаясь к её отрибутам
  With StringGrid1 do
    // Теперь обойдём строки и отсортируем их методом нахождения минимального элемента
    for i:= 1 to n-1 do
    begin
      // Запоминаем индекс текущего элемента
      i_min := i;

      // Ищем минимальный элемент(если такой есть), что ниже текущего
      for j:=i+1 to n do
      begin
        // Фамилия студента храниться во втором столбце - то есть имеет индекс 1
        // Если дальше в списке есть фамилия - что 'меньше' чем у текущего студента
        if (Cells[1, i_min] > Cells[1, j]) then
          i_min:= j;  // Запоминаем индекс этого 'меньшего' студента
      end;

      // Теперь достаточно поменять местами i-ый и минимальный элемент
      // Получаем текущего студента
      GetStud(i, s);
      // Получаем минимального студента
      GetStud(i_min, s_min);

      // И меняем их местами(записываем наоборт)
      // минимального на место текущего
      WriteStud(i, s_min);
      // Текущего на место минимального
      WriteStud(i_min, s);
    end;

  // В задании сказано сохранить изменения в файл
  // Для этого достаточно вызвать Обработчик форму {Сохранить}
  // self - как бы показывает что именно к нашей форме Form1 относятся эти действия
  MenuItem5Click(self);
end;

{Обработка 2}
procedure TForm1.MenuItem10Click(Sender: TObject);
begin

end;


end.
