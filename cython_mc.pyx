from libc.stdlib cimport rand, RAND_MAX
from libc.math cimport sqrt, log, cos, sin, exp, M_PI, pow

def random_uniform():
    return rand()/RAND_MAX

def random_normal():
    cdef double x = random_uniform()
    cdef double y = random_uniform()
    return sqrt(-2.0 * log(x+0.00001)) * cos(2 * M_PI * y), sqrt(-2.0 * log(x+0.00001)) * sin(2 * M_PI * y)

def down_and_out_option(int n_path, double barrier, double s, 
                         double k, double sigma, double T, double r):
    cdef double x_mean = 0.#for monte carlo
    cdef double x_mean_squared = 0.#for monte carlo

    cdef int path_lenth = int(T * 252)
    cdef double dt = T / path_lenth
    cdef double dr = (r - pow(sigma, 2.)/2.) * dt
    cdef double dsigma = sigma * (pow(dt, 0.5))
    cdef int i, j
    cdef double tmp_s, tmp_s2, tmp_s3, tmp_s4, avg_payoff
    
    print("n_path:", n_path * 2)

    if s <= barrier:
        return (0., 0.)

    for i in range(n_path):
        tmp_s = s
        tmp_s2 = s
        tmp_s3 = s
        tmp_s4 = s
        for j in range(path_lenth):
            tmp_z, tmp_z2 = random_normal()
            tmp_s = tmp_s * exp(dr + tmp_z * dsigma)
            tmp_s2 = tmp_s2 * exp(dr - tmp_z * dsigma)#Antithetic path
            tmp_s3 = tmp_s3 * exp(dr + tmp_z2 * dsigma)#Second variable from box-muller
            tmp_s4 = tmp_s4 * exp(dr - tmp_z2 * dsigma)#Antithetic path
            if tmp_s <= barrier:
                tmp_s = 0.
            if tmp_s2 <= barrier:
                tmp_s2 = 0.
            if tmp_s3 <= barrier:
                tmp_s3 = 0.
            if tmp_s4 <= barrier:
                tmp_s4 = 0.
            if tmp_s == 0. and tmp_s2 == 0. and tmp_s3 == 0. and tmp_s4 == 0.:
                break

        if tmp_s>=k:
            tmp_s = tmp_s - k
        else:
            tmp_s = 0.
        
        if tmp_s2>=k:
            tmp_s2 = tmp_s2 - k
        else:
            tmp_s2 = 0.
        
        if tmp_s3>=k:
            tmp_s3 = tmp_s3 - k
        else:
            tmp_s3 = 0.
        
        if tmp_s4>=k:
            tmp_s4 = tmp_s4 - k
        else:
            tmp_s4 = 0.
        #Compute the average payoff
        avg_payoff = (tmp_s + tmp_s2 + tmp_s3 + tmp_s4)/4.
        # print("avg_payoff:", avg_payoff)
        x_mean = (x_mean * i + avg_payoff) / (i + 1.)
        x_mean_squared = (x_mean_squared * i + pow(avg_payoff, 2.)) / (i + 1.)
    #return price and Standard Error
    return x_mean, pow((x_mean_squared - pow(x_mean,2.))/(n_path-1), 0.5)