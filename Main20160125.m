global n x y xb xe yb ye
global xcircle ycircle
%np=input('Input the number of projections:\n');
np=30;
%name=input('Input the first number of PIXE data:\n');
name=751002;
%element=input('Input the element symbol:\n','s');
element='Ge';
%x=input('Input the number of Pixels in x direction;\n');
x=182;
%y=input('Input the number of Pixels in y direction;\n');
y=128;

xb=round(x/3);xe=round(x/3*2);yb=round(y/3);ye=round(y/3*2);
%找边缘，xb为X轴开始位置，xe为X轴结束位置，yb为Y轴开始位置，ye为Y轴结束位置
%用1/3应该是为了减少计算量？
alpha=0:pi/50:2*pi;
xcircle=50*cos(alpha);ycircle=50*sin(alpha);


%——————————————————————————————————
%导入Ge和Zn的PIXE数据，并调用MovetoCenter函数调整图像到扫描范围的中央
PIXE=zeros(y,x,np);PIXEZn=zeros(y,x,np);CenteredPIXE=zeros(y,x,np);
n=1;
while n<=np
    fileID=fopen([num2str(name),'P0',element,'.csv'],'r');
    if fileID==-1
       name=name+1;
       continue
    end
    PIXE(y:-1:1,(x-y)/2+1:(x+y)/2,n)=importdata([num2str(name),'P0',element,'.csv']);
    fclose(fileID);
    %fileID=fopen([num2str(name),'P0','Zn','.csv'],'r');
    PIXEZn(y:-1:1,(x-y)/2+1:(x+y)/2,n)=importdata([num2str(name),'P0','Zn','.csv']);
    %fclose(fileID);
    PIXE(:,:,n)=PIXE(:,:,n)-PIXEZn(:,:,n)*0.14;
    CenteredPIXE(:,:,n)=MovetoCenter(PIXE(:,:,n),n);
    n=n+1;
    name=name+1;
end
set(gcf,'visible','on');
delete(gcf);


%——————————————————————————————————
%
ProjectionPIXE=zeros(x,np,y);
for j=1:1:y
    for k=1:1:np
            ProjectionPIXE(:,k,j)=CenteredPIXE(j,:,k); %i corresponding to x,j corresponding to y,k corresponding to np
    end
end

%anglemin=input('Begining angle of rotation\n');
anglemin=0;
%anglemax=input('Ending angle of rotation\n');
anglemax=174;
%step=input('Rotation step\n');
step=6;

Iradontrans(ProjectionPIXE(:,:,1),anglemin,step,anglemax,'PIXE Centered','Before');


%if mod(y,10)==2
%    yarray=2:10:y;
%else
%    yarray=[2:10:y,y];
%end

%for k=1:1:(size(yarray,2)-2)
%    Iradontrans(ProjectionPIXE(:,:,yarray(k):(yarray(k+1)-1)),anglemin,step,anglemax,'PIXE Centered','Before');
%end

%Iradontrans(ProjectionPIXE(:,:,yarray(size(yarray,2)-1):y),anglemin,step,anglemax,'PIXE Centered','Before');
Iradontrans(ProjectionPIXE(:,:,2:y),anglemin,step,anglemax,'PIXE Centered','Before');

%____________________________________________________________________________

CorrectionArray=fliplr(FindCorrArray());
CorrectionArray(:,1:27)=1;
CorrectionArray(:,158:185)=1;
CorrCentPIXE=zeros(y,x,np);
for i=1:np 
    CorrCentPIXE(:,:,i)=CenteredPIXE(:,:,i).*CorrectionArray(:,2:183);
    imshow(CorrCentPIXE(:,:,i),[0,260]);
    colormap(jet);
    set(gcf,'visible','off');
    str=sprintf('%d Corrected PIXE Centered Projection',i);
    saveas(gcf,str,'jpg');
end

set(gcf,'visible','on');
delete(gcf);

CorrProjectionPIXE=zeros(x,np,y);

for j=1:1:y
    for k=1:1:np
            CorrProjectionPIXE(:,k,j)=CorrCentPIXE(j,:,k); %i corresponding to x,j corresponding to y,k corresponding to np
    end
end



Iradontrans(CorrProjectionPIXE(:,:,1),anglemin,step,anglemax,'Corrected PIXE Centered','After');


%if mod(y,10)==2
%    yarray=2:10:y;
%else
%    yarray=[2:10:y,y];
%end

%for k=1:1:(size(yarray,2)-2)
%    Iradontrans(CorrProjectionPIXE(:,:,yarray(k):(yarray(k+1)-1)),anglemin,step,anglemax,'Corrected PIXE Centered','After');
%end

%Iradontrans(CorrProjectionPIXE(:,:,yarray(size(yarray,2)-1):y),anglemin,step,anglemax,'Corrected PIXE Centered','After');
Iradontrans(CorrProjectionPIXE(:,:,2:y),anglemin,step,anglemax,'Corrected PIXE Centered','After');

set(gcf,'visible','on');