%�ڶ���
clc;clear;
tic;
t_move_choice=[0,23,41,59];%�ƶ�i����λ����ʱ��
t_odd=30;%RGVΪCNC1#��3#��5#��7#һ������������ʱ��
t_even=35;%RGVΪCNC2#��4#��6#��8#һ������������ʱ��
t_wash=30;%RGV���һ�����ϵ���ϴ��ҵ����ʱ��
iter=0;%��������

while(iter<5000)
 %%
    CNC_num_1=[]; CNC_num_2=[];    down_1st=[]; down_2nd=[];    up_1st=[];  up_2nd=[];    location_all=[]; failure_task=[];
	CNC_order_state_1=[0,0,0];%���ڼ�¼CNCi�������ĸ���ŵ�����
    CNC_order_state_2=[0,0,0,0,0];%���ڼ�¼CNCi�������ĸ���ŵ�����
    CNC_1=[0,0,0];%0��ʾCNCδ�ڼӹ�,��һ������CNC
    CNC_2=[0,0,0,0,0];%0��ʾCNCδ�ڼӹ����ڶ�������CNC
    CNC_worktime_1=[0,0,0];%��һ������CNC�Ѽӹ�ʱ��
    CNC_worktime_2=[0,0,0,0,0];
    CNC_failuretime_1=zeros(1,3);%���ϼ�ʱ
    CNC_failuretime_2=zeros(1,5);%���ϼ�ʱ
    CNC_repairtime_1=zeros(1,3);%��һ�ι���ʱ�޸��õ�ʱ��
    CNC_repairtime_2=zeros(1,5);%��һ�ι���ʱ�޸��õ�ʱ��
    t_delta=0;
    time_all=0;
    location_current=1;%��ʼλ��
    failure_num=0;%���ϴ���
    n=0;
    n2=0;
    n3=0;
    
    %������һ�ι���ʱ�޸��õ�ʱ�䣬��600-1200֮��
    for i=1:3
        CNC_repairtime_1(i)=600+round((1200-600)*rand());
        %CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    for i=1:5
        CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    %���ѡȡ4��Ϊ�ڶ�����
    CNC_procedure=ones(1,8);
    m=zeros(1,5);
    for i=1:5
        while(1)
            a=rem(round(rand()*10),8)+1;
            if(~ismember(a,m))
                m(i)=a;
                break;
            end
        end
        CNC_procedure(m(i))=2;%i��ʾCNCiΪ�ڼ�������
    end
    
    record_1=find(CNC_procedure==1); %��¼ĳ̨CNC�ǵڼ�������һ�������
    record_2=find(CNC_procedure==2); %��¼ĳ̨CNC�ǵڼ������ڶ��������
    
    %���ݹ���ȷ����������ʱ��
    s=0;t=0;
    for i=1:8
        if(CNC_procedure(i)==1)
            s=s+1;
            if(mod(i,2))
                t_1st_uAndD(s)=t_odd;%��һ������CNC����ʱ��
            else
                t_1st_uAndD(s)=t_even;
            end
        else
            t=t+1;
            if(mod(i,2))
                t_2nd_uAndD(t)=t_odd;
            else
                t_2nd_uAndD(t)=t_even;
            end            
        end
    end
      
    while(time_all<=8*3600)
%%
%��һ������
        n=n+1;
        location_all(n,1)=location_current;%��¼����n����1RGV�˶�λ��
        task_procedure(n)=1;%����n���ڵ�һ������
        %��ȥCNC_1���ϣ������ڹ��������,��ȴ������ɵ�һ��
        while(isempty(find(CNC_1==0)))
            a=max(CNC_worktime_1);
            t_delta_1=280-a;
            
            a=max(CNC_failuretime_1);
            if(a>0)
                t_delta_2=CNC_repairtime_1(find(CNC_failuretime_1==a))-a;
            else
                t_delta_2=1e+4;
            end
            
            t_delta=min(t_delta_1,t_delta_2);
            
            time_all=time_all+t_delta;
            
            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
            CNC_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��0
            CNC_worktime_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��ʱ��0
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
            CNC_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��0
            CNC_worktime_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
            index=find(CNC_failuretime_1>=CNC_repairtime_1);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_1(index)=0;%������CNC��0
                CNC_failuretime_1(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];
            
            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
            index=find(CNC_failuretime_2>=CNC_repairtime_2);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_2(index)=0;%������CNC��0
                CNC_failuretime_2(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];
        end
        
        while(1)%�Ը�����������ɵ�CNC_1
            num=rem(round(rand()*10),8)+1;%ȡһ�������ű���

            while(~ismember(num,record_1)||CNC_1(find(record_1==num))==1||CNC_1(find(record_1==num))==2||CNC_procedure(num)==2)%��ǰ����Ϊ��������ȥ��һ������CNC�����Ҹô���δ�ڼӹ�
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
        
        t_delta=t_1st_uAndD(find(record_1==num));
                             
        time_all=time_all+t_move_choice(s+1)+t_delta;
        location_current=ceil(num/2);%���µ�ǰλ��
        
        %��������,��0.01�ĸ��ʣ�������ǰ����
        if(round(99*rand())==0)
            CNC_1(find(record_1==num))=2;
            failure_num=failure_num+1;
            failure_task(failure_num,1)=n;%��¼���ϵ��������
            failure_task(failure_num,2)=num;%��¼���ϵ�CNC
            failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta;%��¼CNC���ϵĿ�ʼʱ��
            failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_repairtime_1(find(record_1==num));%��¼CNC���ϵĽ���ʱ��
        end        
        
        CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��           
        CNC_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��0
        CNC_worktime_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��ʱ��0
        
        if(CNC_1(find(record_1==num))==0)
            CNC_1(find(record_1==num))=1;%����CNC_1״̬
        end
        
        CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
        CNC_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��0
        CNC_worktime_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��ʱ��0
        
        CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
        index=find(CNC_failuretime_1>=CNC_repairtime_1);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC_1(index)=0;%������CNC��0
            CNC_failuretime_1(index)=0;%������CNC��0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];

        CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
        index=find(CNC_failuretime_2>=CNC_repairtime_2);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC_2(index)=0;%������CNC��0
            CNC_failuretime_2(index)=0;%������CNC��0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
            end
        end
        index=[];
        
        up_1st(n+1)=time_all-t_delta;%��¼����n+1����1����ʱ��
        if(CNC_order_state_1(find(record_1==num))~=0)
            n2=CNC_order_state_1(find(record_1==num));%��ǰҪ���ϵ����ϵ���ţ���ȷ����Ҫ���ڶ�����������ϵ����
            down_1st(n2)=time_all-t_delta;%��¼����n2����1����ʱ��
        end
        
        CNC_num_1(n)=num;%��¼����n�Ĺ���1CNC���
        if(CNC_1(find(record_1==num))==2)%��¼��ǰCNC_1��������n������
            CNC_order_state_1(find(record_1==num))=0;
        else
            CNC_order_state_1(find(record_1==num))=n;
        end
 %%
 %�ڶ�������
         if(n2~=0)
            location_all(n2,2)=location_current;%��¼����n����2RGV�˶�λ��
            task_procedure(n2)=2;%����n���ڵڶ�������

            %ȥCNC_2���ϣ������ڹ��������,��ȴ������ɵ�һ��
            while(isempty(find(CNC_2==0)))
                a=max(CNC_worktime_2);
                t_delta=500-a;
                
                a=max(CNC_failuretime_2);
                if(a>0)
                    t_delta_2=CNC_repairtime_2(find(CNC_failuretime_2==a))-a;
                else
                    t_delta_2=1e+4;
                end

                t_delta=min(t_delta_1,t_delta_2);

                time_all=time_all+t_delta;

                CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
                CNC_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��0
                CNC_worktime_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��ʱ��0

                CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
                CNC_1(find(CNC_worktime_1>=288))=0;%�ӹ���CNC��0
                CNC_worktime_1(find(CNC_worktime_1>=288))=0;%�ӹ���CNC��ʱ��0
                
                CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
                index=find(CNC_failuretime_1>=CNC_repairtime_1);
                if(~isempty(index))%����������������һ�εĹ�������ʱ��
                    CNC_1(index)=0;%������CNC��0
                    CNC_failuretime_1(index)=0;%������CNC��0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                    end
                end
                index=[];

                CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
                index=find(CNC_failuretime_2>=CNC_repairtime_2);
                if(~isempty(index))%����������������һ�εĹ�������ʱ��
                    CNC_2(index)=0;%������CNC��0
                    CNC_failuretime_2(index)=0;%������CNC��0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                    end
                end
                index=[];
            end

            while(1)%�Ը�����������ɵ�CNC_2
                num=rem(round(rand()*10),8)+1;%ȡһ�������ű���

                while(~ismember(num,record_2)||CNC_2(find(record_2==num))==1||CNC_2(find(record_2==num))==2||CNC_procedure(num)==1)%��ǰ������Ҫȥ�ڶ�������CNC�����Ҹô���δ�ڼӹ�
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

            t_delta=t_2nd_uAndD(find(record_2==num));

            time_all=time_all+t_move_choice(s+1)+t_delta;
            location_current=ceil(num/2);%���µ�ǰλ��
            
            %��������,��0.01�ĸ��ʣ�������ǰ����
            if(round(99*rand())==0)
                CNC_2(find(record_2==num))=2;
                failure_num=failure_num+1;
                failure_task(failure_num,1)=n2;%��¼���ϵ��������
                failure_task(failure_num,2)=num;%��¼���ϵ�CNC
                failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta;%��¼CNC���ϵĿ�ʼʱ��
                failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_repairtime_2(find(record_2==num));%��¼CNC���ϵĽ���ʱ��
            end 

            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��           
            CNC_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��0
            CNC_worktime_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��ʱ��0

            if(CNC_2(find(record_2==num))==0)
                CNC_2(find(record_2==num))=1;%����CNC_1״̬
            end

            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
            CNC_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��0
            CNC_worktime_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
            index=find(CNC_failuretime_1>=CNC_repairtime_1);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_1(index)=0;%������CNC��0
                CNC_failuretime_1(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];

            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
            index=find(CNC_failuretime_2>=CNC_repairtime_2);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_2(index)=0;%������CNC��0
                CNC_failuretime_2(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];

            time_all=time_all+t_wash;
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_wash;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
            CNC_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��0
            CNC_worktime_2(find(CNC_worktime_2>=500))=0;%�ӹ���CNC��ʱ��0

            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_wash;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
            CNC_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��0
            CNC_worktime_1(find(CNC_worktime_1>=280))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
            index=find(CNC_failuretime_1>=CNC_repairtime_1);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_1(index)=0;%������CNC��0
                CNC_failuretime_1(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];

            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
            index=find(CNC_failuretime_2>=CNC_repairtime_2);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_2(index)=0;%������CNC��0
                CNC_failuretime_2(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                end
            end
            index=[];

            up_2nd(n2)=time_all-t_delta-t_wash;%��¼����n2����2����ʱ��
            if(CNC_order_state_2(find(record_2==num))~=0)
                n3=CNC_order_state_2(find(record_2==num));%��ǰҪ���ϵ����ϵ���ţ���ȷ������ɵڶ�������ȴ���ϴ�����ϵ����
                down_2nd(n3)=time_all-t_delta-t_wash;%��¼����n3����2����ʱ��
            end

            CNC_num_2(n2)=num;%��¼����n2�Ĺ���2CNC���
            if(CNC_2(find(record_2==num))==2)%��¼��ǰCNC_1��������n������
                CNC_order_state_2(find(record_2==num))=0;
            else
                CNC_order_state_2(find(record_2==num))=n;
            end  
         end
    end
    iter=iter+1;
    location_save{iter}=location_all(1,:);%����ÿһ�ε�·��
    down_1st_save{iter}=down_1st(1,:);%����ÿһ�εĵ�һ����������ʱ��
    up_1st_save{iter}=up_1st(1,:);%����ÿһ�εĵ�һ����������ʱ��
    down_2nd_save{iter}=down_2nd(1,:);%����ÿһ�εĵڶ�����������ʱ��
    up_2nd_save{iter}=up_2nd(1,:);%����ÿһ�εĵڶ�����������ʱ��
    CNC_num_1_save{iter}=CNC_num_1(1,:);%����ÿһ�εĹ���1CNC�ӹ��������
    CNC_num_2_save{iter}=CNC_num_2(1,:);%����ÿһ�εĹ���2CNC�ӹ��������
    task_num(iter,:)=n;%����ÿһ�ε����������
    failure_num_save(iter,:)=failure_num;%����ÿһ�εĹ��ϴ���
    failure_task_save{iter}=failure_task;%����ÿһ�εĹ��ϼ�¼
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