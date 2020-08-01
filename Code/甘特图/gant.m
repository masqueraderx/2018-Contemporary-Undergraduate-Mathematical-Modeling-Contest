%һ������
clc,clear all;
t_start=[6377,6321,6192,6139,6066,5980,5924,5835,5697,5644,5555,5502]';%���Ͽ�ʼʱ��
t_end=[7001,6945,6833,6780,6707,6621,6565,6476,6321,5644,6192,6139]';%���Ͽ�ʼʱ��
jobname=[1,2,6,5,7,3,4,8,2,1,6,5]';%�ӹ�CNC���
[m n]=size(t_start);
axis_size=[5450 7050 69 82];
axis(axis_size);
m=82;
yla=[69:m];
set(gca,'ytick',yla);
ylabel('�ӹ����ϱ��','FontSize',12,'color','b');
xlabel('�ӹ�ʱ��','FontSize',12,'color','b');
title('������������ϸ���ͼ','FontSize',16,'color','r');
set(gcf,'Color','w')
hold on

ZO=m+1;
for i=1:m-70
    for j=1:n
        x=[t_start(i,j) t_start(i,j) t_end(i,j) t_end(i,j)];
        y=[ZO-i-0.3 ZO-i+0.3 ZO-i+0.3 ZO-i-0.3];
      switch(jobname(i,j))         
              case 1  
                  fill(x,y,'y');
              case 2 
                  fill(x,y,'m');
              case 3  
                  fill(x,y,'c');
              case 4 
                  fill(x,y,'r');
              case 5  
                  fill(x,y,'g');
              case 6 
                  fill(x,y,'b');
              case 7
                  fill(x,y,'k');
              case 8
                  fill(x,y,'y')           
      end
      %��ͬ���CNC���費ͬ��ɫ��ע   
      jobnamestr=strcat(int2str(jobname(i,j)));
      t_startstr=strcat(int2str(t_start(i,j)));
      t_endstr=strcat(int2str(t_end(i,j)));
      %��ͼ�б�עCNC���
      text((t_start(i,j)+t_end(i,j))/2-0.2,ZO-i,jobnamestr);
      text(t_start(i,j)-0.2,ZO-i-0.5,t_startstr);
      text(t_end(i,j)-0.2,ZO-i-0.5,t_endstr);
      hold on
   end
end