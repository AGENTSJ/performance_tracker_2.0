class CommonService {

  double getPercentage(double total ,double part)
  {
    if(total==0)
    {
      return 0;
    }
    return (part / total)*100;
  }
}