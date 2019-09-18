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

  // Сначала нужно очистить таблицу от предыдущих записей
  ClearTab;
  // Например если мы загрузим НОВЫЙ файл, число записей в котором МЕНЬШЕ
  // чем в ПРЕДЫДУЩИМ, то снизу останутся строки старого файла
  // А если мы ВПЕРВЫЕ открываем файл в табличном редакторе, то
  // функция ClearTab просто ничего не будет делать
  
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

{Сортировка по группам}
procedure TForm1.MenuItem9Click(Sender: TObject);
var f: file of Stud; // файловая переменная (файл наших студентов)
    s_table: Stud; // студет, которого будем записывать в файл (из ТАБЛИЦЫ)
    s_file: Stud; // студент из файла, с ним будет сравниваться ВСТАВЛЯЕМЫЙ в файл студент s
    i: integer; // счётчик студентов в таблице
    j: integer;
    // Номер студента в файле
    // при записи нового студента в файл мы будем просматривать других студентов
    // то есть будем считывать их из ТИПИЗИРОВАННОГО фйла
    // для этого нужно будет запоминать номера прочтённых студентов
    // так же так как файл ТИПИЗИРОВАННЫЙ то используя номер студента мы можем
    // перейти к позиции в файле где расположен студент и прочитать его
    number_stud: integer; // счётчик студентов файле
    index_ins: integer; // индекс вставки - на какое место вставляем студента в файл
begin
  // Здесь считаем, что пользователь уже открыл файл в табличном редакторе
  // то есть sf - не пустая

  // Очищаем файл и открываем его на ЗАПИСЬ
  AssignFile(f, sf);
  Rewrite(f);

  // Сначала запишем одного студента в файл - пусть это будет 1-ый в таблице
  // хоть строки в StringGrid1 нумеруются с 1, но самая первая строка r = 0
  // это строка заголовка

  // Получаем 1-го студента из таблицы таблицы
  // так же как в процедуре SaveToFileOfStud
  s_table.No   := StrToInt(StringGrid1.Cells[0,1]); // Заполняем Номер студента
  s_table.Name := StringGrid1.Cells[1,1];           // Получаем  Фамилию студента
  s_table.Gr   := StringGrid1.Cells[2,1];           // Группа студента
  // Оценки
  s_table.o1   := StrToInt(StringGrid1.Cells[3,1]);
  s_table.o2   := StrToInt(StringGrid1.Cells[4,1]);
  s_table.o3   := StrToInt(StringGrid1.Cells[5,1]);

  // записываем его в файл
  write(f, s_table);
  // закрываем файл
  CloseFile(f);

  // действия проводимые выше нужны, что при записи нового студента в файл
  // там был хотя бы один студент, с которым можно будет сравнить название группы

  // Открываем файл на чтение И запись
  Reset(f);

  // дальше обходим остальные строки
  // 2 так как считаем что 1-го студента обработали
  i := 2;
  // Используем with, чтобы меньше его писать после
  with StringGrid1 do
  begin
    // у нас в таблице есть пустые строки, поэтому обходим их так
    // счётчик студентов должен быть меньше числа строк в таблице
    // и строка таблицы не должна быть пустой
    // нет необходимости проверять все строки таблицы
    // если первый столбец таблицы - пустой следовательно и строка пустая
    // а значит дальше смотреть строки не имеет смысла - они тоже пустые
    // выходим в этом случае из цикла while
    while( (i < RowCount) and (Cells[0,i] <> '')) do
    begin
      // Получаем одного(i-го) студента таблицы
      // так же как в процедуре SaveToFileOfStud
      s_table.No   := StrToInt(Cells[0,i]); // Заполняем Номер студента
      s_table.Name := Cells[1,i];           // Получаем  Фамилию студента
      s_table.Gr   := Cells[2,i];           // Группа студента
      // Оценки
      s_table.o1   := StrToInt(Cells[3,i]);
      s_table.o2   := StrToInt(Cells[4,i]);
      s_table.o3   := StrToInt(Cells[5,i]);

      // Увеличиваем счётчик записей о студентах в таблице
      i := i + 1;

      // Записываем его в файл так, чтобы группы студентов были упорядочены

      // готовимся к чтению из файла

      // указатель говорит программе с какого места читать файл
      // ставим указатель в файле всначло, нужно ведь обойти студентов в файле
      seek(f, 0);

      // начальное значение счётчика студентов файле = 0
      // то есть пока никого ещё не читали из файла
      number_stud := 0;
      // сначла считаем, что у студента название группы меньше всех
      // строки - названия групп тоже можно сравнивать как и числа
      // мы будем записывать студентов 'меньших' групп в начало
      // чтобы была упорядоченность
      index_ins:= 1; // поэтому номер студента 1 - на первое место
      // Обходим файл студентов
      while(not EOF(f)) do
      begin
        // Считываем одного студента из файла
        read(f, s_file);
        // увеличиваем счётчик студентов файле
        number_stud := number_stud + 1;

        // если его группа( студента из файла)
        // меньше названия группы студента из таблицы
        if (s_file.Gr < s_table.Gr) then
          // запоминаем позицию куда надо вставить студента
          // то есть ПОСЛЕ текущго в файле вставляем
          index_ins:= number_stud+1;

        // отдельно рассмотрим случай - когда группы студентов совпадают
        // тогда надо вставлять этих студентов - по возрастании НОМЕРОВ
        // у кого номер больше - тех ставим ниже
        if(s_file.Gr = s_table.Gr) then
          // если у вставляемого студента - номер БОЛЬШЕ - его ставим ПОСЛЕ
          if (s_table.No > s_file.No) then
            index_ins := number_stud+1
          // иначе ставим перед
          else
            index_ins := number_stud;
      end;

      // Здесь мы уже получили позицию, куда вставлять студента index_ins
      // Надо остальных студентов, что ЛЕВЕЕ этой позиции подвинуть ВЛЕВО

      // Поэтому с конца файла идём к этой позиции и сдвигаем их влево
      for j:= FileSize(f) downto index_ins do
      begin
        // Ставим указатель перед j-ым ситудентом
        seek(f, j-1);
        // Считываем этого студента
        read(f, s_file);
        // У нас указатель автоматически переместился ЗА позицию этого студента
        // то есть укзатель переместился ВЛЕВО после операции ЧТЕНИЯ (read)
        // То что нами и надо, поэтому просто можем его дальше записать
        write(f, s_file);
      end;
      {
       допустим index_ins = 4
       То есть
       было :      s1 s2 s3 s4 s5 s6
       стало:      s1 s2 s3 s4 s4 s5 s6
                            ^
                            |
             дальше запишем студента из таблицы сюда
             index_ins = 4 остался таким же
      }

      // ставим указатель на позицию куда надо вставлять студента из таблицы
      seek(f, index_ins-1);
      // и записываем туда студента
      write(f, s_table);
    end;
  end;

// после всех действий закрываем файл студентов
CloseFile(f);

// Для удобства загрузим изменённый файл в нашу таблицу
LoadFromFileOfStud;

// так как файл такой же на диске как и в таблицк
// файл мы не изменяли
StringGrid1.Modified := False;

end;

{Соответствует ли фамилия студента (surname) маске (maska)}
// в маске может находиться символ замещения ?
// что обозначет любой один символ
// знаков '?' в маске может быть сколько угодно раз
// Название функции переводится - 'Такаое имя возможно?'
function isNamePossibly(maska: string; surname: string): boolean;
var res: boolean; // переменная, куда запишем результат работы функции
    i: integer;
begin
  // сначала считаем, что строка соответствует маске
  // если это не так, то мы позже изменим это значение
  res:= True;

  // по условию длина строки маски maska и длина проверяемой строки surname
  // должны быть равны, хоть ? и заменятся на любой другой символ, но он не меняет длину строки
  // length(maska) = length(surname)
  // тогда если длины строк не равны - то значит строка не соответствует маске
  if (length(maska) <> length(surname)) then
    res:= False

  // Иначе просто обходим каждые символы маски и проверяемой строки
  // заметим что здесь уже length(maska) = length(surname) - можно использовать любую длину
  else
    for i:=1 to length(maska) do
    begin
      // если соответствующие символы маски и строки не совпадают
      // и причом не совпадающий символ в маске - НЕ знак вопроса
      // строка st - не соответствует маске
      if (maska[i] <> surname[i]) and(maska[i] <> '?') then
      begin
        res:= False; // Говорим, что не соответствует
        break;       // досрочно выходим из цикла - так как нет смысла смотреть символы дальше
      end;
    end;

  // Присваиваем результат нашей работы имени функции - это то что она вернёт
  isNamePossibly := res;
end;


{Выбор по маске}
procedure TForm1.MenuItem10Click(Sender: TObject);
var maska: string; // маска вводимая пользователем
    f: file of Stud; // переменная для работы с файлом студентов
    s: Stud; // студент которого будем считывать из файла
    i_table: integer; // счётчик записанных студентов в таблицу
begin
  // Получаем маску от пользователя
  maska := inputbox('Ввод маски', 'Используйте символ "?"', '???o?cov');

  // Переед записью в StringGrid1 её надо очистить
  ClearTab;

  // Здесь считаем, что юзер УЖЕ открыл файл в табличном редакторе
  // то есть sf - не пустая

  // Открываем файл студентов на ЧТЕНИЕ
  AssignFile(f, sf);
  Reset(f);

  // пока мы ещё не записали ни одного студента в таблицу
  // будем записывать с первой строки(не нулевой - это заголовок)
  i_table := 1;

  // Обходим всех студентов в файле
  while (not EOF(f)) do
  begin
    // считываем одного студента
    read(f, s);

    // если его фамилия подходит маске
    if (isNamePossibly(maska, s.Name)) then
    begin
      // то записываем его в таблицу
      // нашли номер строки - теперь туда запишем студента
      StringGrid1.Cells[0,i_table]:= IntToStr(s.No);  // Его Номер
      StringGrid1.Cells[1,i_table]:= s.Name;          // Фамилия
      StringGrid1.Cells[2,i_table]:= s.Gr;            // Группа
      StringGrid1.Cells[3,i_table]:= IntToStr(s.o1);
      StringGrid1.Cells[4,i_table]:= IntToStr(s.o2);   {И оценки}
      StringGrid1.Cells[5,i_table]:= IntToStr(s.o3);

      // увеличиваем счётчик записанных студентов в таблцу
      i_table := i_table + 1;
    end;

  end;
  // Прочитали весь файл - надо его закрыть
  CloseFile(f);

  // Мы что-то записывали в StringGrid1, но файл не меняли
  StringGrid1.Modified := False;
end;


end.
