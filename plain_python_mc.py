import numpy as np

def down_and_out_option_py(n_path, barrier, s, k, sigma, T, r):
    x_mean = 0#for monte carlo
    x_mean_squared = 0#for monte carlo

    path_lenth = int(T * 252)
    dt = T / path_lenth
    dr = (r - (sigma**2)/2) * dt
    dsigma = sigma * ((dt) ** 0.5)

    if s <= barrier:
        return 0

    print("n_path:", n_path)

    for i in range(n_path):
        tmp_s = s
        tmp_s2 = s
        for _ in range(path_lenth):
            tmp_z = np.random.normal(0, 1)
            if tmp_s <= barrier:
                tmp_s = 0
            if tmp_s2 <= barrier:
                tmp_s2 = 0
            if tmp_s == 0 and tmp_s2 == 0:
                break
            tmp_s = tmp_s * np.exp(dr + tmp_z * dsigma)
            tmp_s2 = tmp_s2 * np.exp(dr - tmp_z * dsigma)#Antithetic path
        payoff = max(tmp_s - k, 0)
        payoff2 = max(tmp_s2 - k, 0)
        avg_payoff = (payoff + payoff2)/2
        x_mean = (x_mean * i + avg_payoff) / (i + 1)
        x_mean_squared = (x_mean_squared * i + avg_payoff**2) / (i + 1)
    out = x_mean
    se = ((x_mean_squared - x_mean**2)/(n_path-1))**0.5

    return out, se
    