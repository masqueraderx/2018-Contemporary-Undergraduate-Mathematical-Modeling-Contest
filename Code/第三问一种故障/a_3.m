%������
clc;clear;
tic;
t_move_choice=[0,18,32,46];%�ƶ�i����λ����ʱ��
t_process_1= 545;%CNC�ӹ����һ��һ���������������ʱ��
t_odd=27;%RGVΪCNC1#��3#��5#��7#һ������������ʱ��
t_even=32;%RGVΪCNC2#��4#��6#��8#һ������������ʱ��
t_wash=25;%RGV���һ�����ϵ���ϴ��ҵ����ʱ��
t_task_odd=t_odd;
t_task_even=t_even;
m=0;

while(m<5000)
    CNC_num=[];    down=[];    up=[];    location_all=[]; failure_task=[];
	CNC_order_state=[0,0,0,0,0,0,0,0];%���ڼ�¼CNCi�������ĸ���ŵ�����
    CNC=[0,0,0,0,0,0,0,0];%0��ʾCNCδ�ڼӹ�
    CNC_worktime=[0,0,0,0,0,0,0,0];
    
    CNC_failuretime=zeros(1,8);%���ϼ�ʱ
    CNC_repairtime=zeros(1,8);%��һ�ι���ʱ�޸��õ�ʱ��
    
    %������һ�ι���ʱ�޸��õ�ʱ�䣬��600-1200֮��
    for i=1:8
        CNC_repairtime(i)=600+round((1200-600)*rand());
    end
    
    t_delta=0;
    time_all=0;
    location_current=1;%��ʼλ��
    
    n=0;
    failure_num=0;%���ϴ���
    
    while(time_all<=8*3600)
        n=n+1;
        location_all(n)=location_current;%��¼RGV�˶�λ��

        %�����ڹ��������,��ȴ������ɵ�һ��
        while(isempty(find(CNC==0)))
            a=max(CNC_worktime);
            t_delta_1=545-a;
            
            a=max(CNC_failuretime);
            if(a>0)
                t_delta_2=CNC_repairtime(find(CNC_failuretime==a))-a;
            else
                t_delta_2=1e+4;
            end
            
            t_delta=min(t_delta_1,t_delta_2);
            
            time_all=time_all+t_delta;
            
            CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_delta;%�����������ӹ���CNC���Ѽӹ�ʱ��
            CNC(find(CNC_worktime>=545))=0;%�ӹ���CNC��0
            CNC_worktime(find(CNC_worktime>=545))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_delta;%�������������ϵ�CNC���ѹ���ʱ��
            index=find(CNC_failuretime>=CNC_repairtime);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC(index)=0;%������CNC��0
                CNC_failuretime(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];
        end
        
        while(1)%�Ը�������
            num=rem(round(rand()*10),8)+1;%ȡһ�������ű���
            while(CNC(num)==1||CNC(num)==2)%��Ŀ���ڹ�������ϣ������Ŀ��
                num=rem(round(rand()*10),8)+1;%ȡһ�������ű���
            end
            s=abs(location_current-ceil(num/2));%��Ŀ��CNC�ľ���
            if(s==0)
                break;
            end
            if(s==1)
                if(rand()<1/2)
%                 if(rand()<0.6)
                    break;
                end
            end
            if(s==2)
                if(rand()<1/3)
%                 if(rand()<0.3)
                    break;
                end
            end
            if(s==3)
                if(rand()<1/6)
%                 if(rand()<0.1)
                    break;
                end
            end
        end
                             
        %�ж���ż
        if(mod(num,2))
            t_delta=t_task_odd;
        else
            t_delta=t_task_even;
        end
        
        location_current=ceil(num/2);%���µ�ǰλ��
        
        %��������,��0.01�ĸ��ʣ�������ǰ����
        if(round(99*rand())==0)
            CNC(num)=2;
            failure_num=failure_num+1;
            failure_task(failure_num,1)=n;%��¼���ϵ��������
            failure_task(failure_num,2)=num;%��¼���ϵ�CNC
            failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta;%��¼CNC���ϵĿ�ʼʱ��
            failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_repairtime(num);%��¼CNC���ϵĽ���ʱ��
        end
        
        time_all=time_all+t_move_choice(s+1)+t_delta;
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC���Ѽӹ�ʱ��
        
        if(CNC(num)==0)
            CNC(num)=1;%����CNC״̬
        end
        
        CNC(find(CNC_worktime>=545))=0;%�ӹ���CNC��0
        CNC_worktime(find(CNC_worktime>=545))=0;%�ӹ���CNC��ʱ��0
        
        CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_move_choice(s+1)+t_delta;%�������������ϵ�CNC���ѹ���ʱ��
        index=find(CNC_failuretime>=CNC_repairtime);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC(index)=0;%������CNC��0
            CNC_failuretime(index)=0;%������CNC��0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];
        
        
        time_all=time_all+t_wash;
        CNC_worktime(find(CNC==1))=CNC_worktime(find(CNC==1))+t_wash;%�����������ӹ���CNC���Ѽӹ�ʱ��
        
        CNC(find(CNC_worktime>=545))=0;%�ӹ���CNC��0
        CNC_worktime(find(CNC_worktime>=545))=0;%�ӹ���CNC��ʱ��0
        
        CNC_failuretime(find(CNC==2))=CNC_failuretime(find(CNC==2))+t_wash;%�������������ϵ�CNC���ѹ���ʱ��
        index=find(CNC_failuretime>=CNC_repairtime);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC(index)=0;%������CNC��0
            CNC_failuretime(index)=0;%������CNC��0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];
        
        
        up(n+1)=time_all-t_delta-t_wash;%��¼����ʱ��
        if(CNC_order_state(num)~=0)
            down(CNC_order_state(num))=time_all-t_delta-t_wash;%��¼����ʱ��
        end
        
        CNC_num(n)=num;%��¼CNC��Ŵ���
        if(CNC(num)==2)
            CNC_order_state(num)=0;
        else
            CNC_order_state(num)=n;
        end
    end
    m=m+1;
    location_save{m}=location_all(1,:);%����ÿһ�ε�·��
    down_save{m}=down(1,:);%����ÿһ�ε�����ʱ��
    up_save{m}=up(1,:);%����ÿһ�ε�����ʱ��
    CNC_num_save{m}=CNC_num(1,:);%����ÿһ�ε�CNC�ӹ��������
    task_num(m,:)=n;%����ÿһ�ε����������
    failure_num_save(m,:)=failure_num;%����ÿһ�εĹ��ϴ���
    failure_task_save{m}=failure_task;%����ÿһ�εĹ��ϼ�¼
end
max(task_num)
find(task_num==max(task_num))
% filetitle='C:\Users\Arthur\Documents\MATLAB\����\result.xlsx';
% %�洢��excel��λ�ú�����
% for i=1:m
%     if isempty(location_save{i})
%     continue;
%     else
%         xlrange=['A',num2str(i)];
%         %�洢����е�λ��,һ�δ�һ��
%         xlswrite(filetitle,location_save{i},'sheet1',xlrange);
%         %�洢ÿ������
%     end
% end
toc;