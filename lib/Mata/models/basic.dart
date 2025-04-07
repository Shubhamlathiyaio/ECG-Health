class Basic
{
  Basic();
  static average(List list)
  {
    num sum=0;
    for(var e in list) sum+=e;
    return sum/list.length;
  }
  static List range({int start=0, required int stop, int step=1}) => List.generate(stop - start + step, (i) => i + start);
}