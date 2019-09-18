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

{Прочитать студента s из таблицы со строки под номером i}
// var s - так как мы меняем значение переменной s
procedure ReadStud(var s: Stud; i: integer);
begin
  // Используем with чтобы меньше писать Form1.StringGrid1.Cells
  With Form1.StringGrid1 do
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

{Записать одного студента s в строку c номером i}
procedure WriteStud(s: Stud; i: integer);
begin
  // Используем with чтобы меньше писать Form1.StringGrid1.Cells
  With Form1.StringGrid1 do
  begin
    // Записываем данные о студенте в таблицу в строку с номером i
    Cells[0,i]:= IntToStr(s.No);  // Его Номер
    Cells[1,i]:= s.Name;          // Фамилия
    Cells[2,i]:= s.Gr;            // Группа
    Cells[3,i]:= IntToStr(s.o1);
    Cells[4,i]:= IntToStr(s.o2);   {И оценки}
    Cells[5,i]:= IntToStr(s.o3);
  end;
end;

{ВСТАВЛЯЕМ студента в строку таблицы c номером r}
// отличается от WriteStud тем, что отодвигает студентов,
// что расположены НИЖЕ данной строки r
{
   до есть допустим нам надо ВСТАВИТЬ студента s в таблицу на третью позицию

   s1 s2 s3 s4 s5 s6

   если бы мы использовали просто WriteStud студент s3 просто ЗАТЕРСЯ
   s1 s2 s  s4 s5 s6

   Поэтому надо сдвинуть студентов ниже позиции 3 на одну позицию
   и вставить студента

   s1 s2 s  s3 s4 s5 s6

   Это как раз делает Процедура InsertStud
}
// n - число студентов в таблице
procedure InsertStud(r: integer; n: integer; s: Stud);
// рабочая переменная студента - для перестановки студентов в Таблице
var s_rab: Stud;
    i: integer;
begin
  // Сдвигаем студентов что НИЖЕ строки r на одну позицию
  for i := n downto r do
  begin
    ReadStud(s_rab, i);
    WriteStud(s_rab, i+1); // то есть записывае на одну позицию ниже
  end;

  {
    допустым r - равно 3
    было: s1 s2 s3 s4 s5 s6
   cтало: s1 s2 s3 s3 s4 s5 s6
  }

  // теперь мы видим что у нас повторяютя два s3 элемента
  // записав s на третью позицию(r) мы получим
  // s1 s2 s s3 s4 s5 s6
  // Всё студента вставили на третье место и НЕ стёрли старых

  // Записываем студента s на позицию r
  WriteStud(s, r);
end;

{Функция возвращает средний балл студента s}
// возвращает вещественное число
function AverageMark(s: Stud): real;
begin
  // То ,что мы присваиваем имени функции,
  // является результатом работы этой функции
  AverageMark := (s.o1 + s.o2 + s.o3)/3;
end;

{Сортировка при чтении}
procedure TForm1.MenuItem9Click(Sender: TObject);
var f: file of Stud; // файл со студентами
    s: Stud; // Студент, которого мы считываем из файла и записываем в таблицу
    // рабочая переменная студента
    // - она служит для считывания и обработки студентов из ТАБЛИЦЫ
    // не путать с s
    // s- только для считывания из файла студента и записи его в таблицу
    s_rab: Stud;
    // индекс вставки - индекс строки в таблице - куда ВСТАВЛЯЕМ студента s
    i_ins: integer;
    i: integer; // для перебора студентов в таблице
    n: integer; // текущее число студентов УЖЕ записанных в таблицу
begin
  // здесь мы считаем что пользователь уже открыл файл в текстовом редакторе
  // и переменная sf(имя файла) - не пустая

  // Открываем файл студентов на ЧТЕНИЕ
  AssignFile(f, sf);
  Reset(f);

  // Перед записью в таблицу - очищаем её
  ClearTab;

  // Изначально считаем что в файле нет студентов - следовательно и нет в таблице
  // если при чтения файла найдутся студенты, то мы увеличим счётчик студентов
  n := 0;

  // Обходим всех студентов в файле
  while(not EOF(f)) do
  begin
     // считываем одного студента из файла
     read(f, s);

     // Теперь находим на какое место записать его в таблицу

     // Изначально считаем что у студента s - самый лучший средний балл
     // е его надо записать на первое место
     // Если появится студент у которого средний балл лучше - то
     // то изменим индекс вставки
     i_ins := 1;

     // Обходим всех студентов из ТАБЛИЦЫ
     // если n = 0 - нет студентов в таблице
     // то НЕ будет ошибки - цикл просто не выполниться,
     // а студента запишут в первую строку i_ins = 1 - выше
     for i := 1 to n do
     begin
        // Считываем студента из таблицы
        ReadStud(s_rab, i);

        // если его средний балл > среднего балла ВСТАВЛЯЕМОГО студента
        if (AverageMark(s_rab) > AverageMark(s)) then
          // тогда мы должны вставить студента на место
          // НИЕЖЕ этого студента
          // ведь записываем по УБЫВАНИЮ средних баллов
          i_ins := i + 1;

        // отдельно рассмотрим сслучай когда средние БАЛЛЫ студентов РАВНЫ
        if (AverageMark(s_rab) = AverageMark(s)) then
        begin
          // таких студентов надо записывать в таблицу по
          // возрастанию номера

          // Если у ВСТАВЛЯЕМОГО студента номер менше чем у студента в таблице
          if (s.No < s_rab.No) then
            // то нужно вставить студента s НА место студента s_rab
            // s_rab подвинуть вниз
            i_ins := i
          // Иначе - когда наоборот, когда
          // у студента в таблице номер меньше чем у вставлояемого студента
          else
            // то ВСТАВЛЯЕМОГО студента s надо вставить в таблицу ПОСЛЕ s_rab
            i_ins:= i + 1;
        end;
     end;

     // Обошли всех студентов в таблице
     // и нашли место куда вставлять студента s
     // Вставляем этого студента на нужное место
     InsertStud(i_ins, n, s);

     // Добавили одного студента -> число студентов в таблице увеличилось
     // увеличиваем счётчик студентов в таблице
     n := n + 1;

     // Переходим к другим студентам в файле
  end;
  // Прочитали весь файл студентов - надо его закрыть
  CloseFile(f);

  // Сохраняем изменённый файл на диск через процедуру {Сохранить}
  // self - это системная переменная - она говорит то эту процедуру вызвала
  // именно процедура из нашей формы
  MenuItem5Click(self);
end;

{сумма баллов одного студента}
function SummPoints(s: Stud): integer;
begin
  // То что мы присваиваем имени функции - это и есть то, что
  // она возвращает после своей работы
  SummPoints := s.o1 + s.o2 + s.o3
end;

{Выбор трёх худших}
procedure TForm1.MenuItem10Click(Sender: TObject);
// вспомогательный файл для обработки плохих студентов
var sup_f: file of Stud;
    s: Stud; // переменная для считывания студентов из файла
    bad_s: Stud; // Плохой студент
    j_bad: integer; // озиция плохого студента в файле
    i, j: integer;
begin
  // здесь мы считаем что пользователь уже открыл файл в текстовом редакторе
  // и переменная sf(имя файла) - не пустая

  // Сначала скопируем исходный файл в вспомогательный
  CopyFile(sf, 'support.dat');

  // в файле support.dat мы будем находить плохого студента
  // потом записыват его в таблицу и потом удалять его из файла
  // чтобы потом уже находить нового плохого студента
  // копируем ИСХОДНЫЙ файл в support.dat - так как нельзя удалять
  // студентов из исходного файла

  // Открываем вспомогательный файл на ЧТЕНИЕ и ЗАПИСЬ
  AssignFile(sup_f, 'support.dat');
  Reset(sup_f);

  // Перед записью в табицу плохихи студентов надо её очистить
  ClearTab;

  //нужно найти трех плохих студентов
  for i:= 1 to 3 do
  begin
    // Ставим указатель в файле на 1
    // указатель говорит с какого места производить ЧТЕНИЕ ил ЗАПИСЬ
    seek(sup_f, 0);

    // считываем одного студента
    read(sup_f, s);

    // Назначаем его плохим
    // если появятся студенты с сумой баллов меньше - то
    // изменим значение этой переменной
    bad_s := s;
    j_bad:= 1;

    // Обходим остальной файл со студентами
    for j:=2 to filesize(sup_f) do
    begin
      // считываем одного студента
      read(sup_f, s);

      // если его сумма баллов меньше суммы баллов ТЕКУЩЕГО плохого студента
      if (SummPoints(s) < SummPoints(bad_s)) then
      begin
        // назначаем этого студента плохим
        bad_s := s;
        // запоминаем его индекс
        j_bad:= j;
      end;

    end;

    // Теперь записываем НАЙДЕННОГО плохого студента в i-ую строку
    WriteStud(bad_s, i);

    // Теперь надо стереть этого плохого студента
    // из вспомогательного файла, чтобы найти другогог плохого студента

    // Для этого сдвигаем все эементы,
    // что НИЖЕ этого элемента на одну позици вверх
    for j:= j_bad+1 to filesize(sup_f) do
    begin
      // Ставим указатель перед j-ым элементом в файле
      seek(sup_f, j-1);

      // считываем одного студента
      read(sup_f, s);

      // ставим укзатель перд j-1 элементом
      seek(sup_f, j-2);

      // Записываем на это место студента s
      write(sup_f, s);
    end;
    {
      то есть было: s1 s2 s3 bad_s s4 s5 s6
             стало: s1 s2 s3 s4    s5 s6 s6
    }

    // Видим что теперь в конце два повторяющихся элемента
    // нужно элемент s6 один оставить - другой удалить

    // Ставим укзатель перед последним элементом в файле
    seek(sup_f, filesize(sup_f)-1);

    // Обрубаем файл
    Truncate(sup_f);

    // стало: s1 s2 s3 s4 s5 s6

    // Теперь ищем слкдующего плохого студента

  end;
  // Нашли всех плохих студентов -> закрываем вспомогательный файл
  CloseFile(sup_f);

  // Теперь вспомогательный файл не нужен - можно его удалить
  Erase(sup_f);

  // Мы изменяли таблицу и ВСПОМОГАТЕЛЬНЫЙ файл
  // НО ИСХОДНЫЙ файл НЕ меняли
  StringGrid1.Modified := False;
end;


end.
